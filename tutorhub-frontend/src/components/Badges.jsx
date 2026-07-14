import clsx from "clsx";

export function StatusBadge({ status }) {
  if (!status) return null;
  return (
    <span className={clsx("badge", `badge-${status}`)}>
      {String(status)}
    </span>
  );
}

export function RoleBadge({ role }) {
  if (!role) return null;
  return (
    <span className={clsx("badge", `badge-${role}`)}>
      {String(role)}
    </span>
  );
}