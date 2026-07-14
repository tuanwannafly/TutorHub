export default function Footer() {
  return (
    <footer className="mt-16 border-t border-hazard-white/10">
      <div className="container-editorial py-8 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div className="flex items-center gap-3">
          <span aria-hidden className="w-7 h-7 rounded-sm bg-mint text-absolute font-display text-lg flex items-center justify-center leading-none">T</span>
          <span className="font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">
            TutorHub — built with Rails 7 + React 18
          </span>
        </div>
        <div className="flex items-center gap-5 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">
          <a href="#" className="hover:text-mint">Github</a>
          <a href="#" className="hover:text-mint">Docs</a>
          <span>© {new Date().getFullYear()}</span>
        </div>
      </div>
    </footer>
  );
}