import { Link } from "react-router-dom";

export default function NotFound() {
  return (
    <div className="container-editorial py-24 text-center">
      <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">/ 404</div>
      <h1 className="font-display text-display-md mt-3 leading-[0.92]">
        NOT <span className="text-mint">HERE.</span>
      </h1>
      <p className="text-hazard-muted text-headline-sm mt-4 max-w-readable mx-auto">
        We couldn't find that page. Try the homepage or browse the directory.
      </p>
      <div className="mt-8 flex justify-center gap-3">
        <Link to="/"        className="pill pill--primary focus-ring">Home</Link>
        <Link to="/tutors"  className="pill pill--secondary focus-ring">Browse tutors</Link>
      </div>
    </div>
  );
}