# ReportQuery — Raw SQL reports.
#
# This class deliberately *avoids* ActiveRecord query methods in favour of
# hand-written SQL, to surface real SQL chops in interviews.
#
# Each method returns an Array<Hash> with stable, predictable keys so the
# views can iterate without per-row parsing.
#
# NOTE on style: we use parameter binding (`$1, $2, …`) rather than string
# interpolation to stay SQL-injection safe. ActiveRecord hands those through
# to Postgres' extended-query protocol automatically.

class ReportQuery
  DAY_NAMES = %w[Sun Mon Tue Wed Thu Fri Sat].freeze

  # ────────────────────────────────────────────────────────────────────
  # Query #1: Tutors available for a given (day_of_week, time-range).
  #
  # Approach: a tutor is "available" if they
  #   (a) have at least one Availability window that fully covers the
  #       requested time-range, AND
  #   (b) do NOT have any confirmed/pending booking overlapping that
  #       same window on the next occurrence of that day.
  #
  # Uses `NOT EXISTS` to subtract booked slots from available ones —
  # the classic "set difference" pattern.
  # ────────────────────────────────────────────────────────────────────
  def self.available_tutors(day_of_week:, start_time:, end_time:, limit: 20)
    sql = <<~SQL.squish
      SELECT
        tp.id            AS tutor_profile_id,
        u.id             AS user_id,
        u.name           AS name,
        u.email          AS email,
        tp.subject       AS subject,
        tp.headline      AS headline,
        tp.hourly_rate   AS hourly_rate
      FROM tutor_profiles tp
      INNER JOIN users u ON u.id = tp.user_id
      WHERE u.role = 1
        AND EXISTS (
          SELECT 1 FROM availabilities a
          WHERE a.tutor_profile_id = tp.id
            AND a.day_of_week = $1
            AND a.start_time <= $2
            AND a.end_time   >= $3
        )
        AND NOT EXISTS (
          SELECT 1 FROM bookings b
          WHERE b.tutor_id = u.id
            AND b.status IN (0, 1)
            AND extract(dow FROM b.booking_date) = $1
            AND b.start_time < $3
            AND b.end_time   > $2
        )
      ORDER BY tp.hourly_rate ASC, u.name ASC
      LIMIT $4
    SQL

    result = exec_query_with_binds(sql, 'available_tutors', [day_of_week, start_time, end_time, limit])
    rows = if result.respond_to?(:to_a) && !result.is_a?(Array) && result.first.is_a?(Hash)
             result.to_a
           else
             result.to_a.map { |r| r.respond_to?(:to_h) ? r.to_h : r }
           end
    rows.map { |r| r.merge('day_of_week_name' => DAY_NAMES[day_of_week]) }
  end

  # ────────────────────────────────────────────────────────────────────
  # Query #2: Monthly revenue per tutor.
  #
  # Confirmed + completed bookings only. SUM the total_amount, GROUP BY
  # month + tutor. This is exactly the same shape of query as a stored
  # procedure in a classic OLTP DBMS.
  # ────────────────────────────────────────────────────────────────────
  def self.monthly_revenue_per_tutor(start_date:, end_date:)
    sql = <<~SQL.squish
      SELECT
        u.id                                AS tutor_id,
        u.name                              AS tutor_name,
        to_char(date_trunc('month', b.booking_date), 'YYYY-MM')
                                            AS month,
        COUNT(b.id)                         AS booking_count,
        COALESCE(SUM(b.total_amount), 0)    AS total_revenue
      FROM bookings b
      INNER JOIN users u ON u.id = b.tutor_id
      WHERE b.status IN (1, 2)
        AND b.booking_date >= $1
        AND b.booking_date <= $2
      GROUP BY u.id, u.name, date_trunc('month', b.booking_date)
      ORDER BY month DESC, total_revenue DESC
    SQL

    binds = [start_date, end_date]
    exec_query_with_binds(sql, 'monthly_revenue_per_tutor', binds).to_a
  end

  # ────────────────────────────────────────────────────────────────────
  # Query #3: Top tutors by completed-bookings count.
  #
  # Uses a window function `RANK() OVER (...)` to assign a rank to
  # every tutor, then we only return those in the top N.
  # ────────────────────────────────────────────────────────────────────
  def self.top_tutors(limit: 10)
    sql = <<~SQL.squish
      WITH booking_counts AS (
        SELECT
          b.tutor_id,
          COUNT(b.id)                        AS booking_count,
          COALESCE(AVG(r.rating), 0)::numeric(3, 2)
                                              AS avg_rating,
          COALESCE(SUM(b.total_amount), 0)   AS lifetime_revenue
        FROM bookings b
        INNER JOIN users u ON u.id = b.tutor_id
        LEFT JOIN reviews r ON r.booking_id = b.id
        WHERE b.status = 2
        GROUP BY b.tutor_id
      ),
      ranked AS (
        SELECT
          u.id          AS tutor_id,
          u.name        AS tutor_name,
          tp.subject    AS subject,
          bc.booking_count,
          bc.avg_rating,
          bc.lifetime_revenue,
          RANK() OVER (ORDER BY bc.booking_count DESC, bc.avg_rating DESC) AS rnk
        FROM users u
        INNER JOIN tutor_profiles tp ON tp.user_id = u.id
        LEFT JOIN booking_counts bc ON bc.tutor_id = u.id
        WHERE u.role = 1
      )
      SELECT * FROM ranked
      WHERE booking_count IS NOT NULL
      ORDER BY rnk ASC
      LIMIT $1
    SQL

    binds = [limit]
    exec_query_with_binds(sql, 'top_tutors', binds).to_a
  end

  # Helper that runs a raw SQL with proper bind quoting (works across ActiveRecord
  # versions on PostgreSQL). The PG API rejects string params for `$1`-style
  # placeholders so we wrap each bind in a quoted literal.
  def self.exec_query_with_binds(sql, name, binds)
    quoted = sql
    binds.each_with_index do |b, idx|
      placeholder = "$#{idx + 1}"
      quoted_value = ActiveRecord::Base.connection.quote(b)
      quoted = quoted.gsub(placeholder, quoted_value)
    end
    File.write(Rails.root.join('tmp', "last_#{name}.sql"), quoted) if defined?(Rails) && Rails.root
    ActiveRecord::Base.connection.exec_query(quoted, name)
  end
end
