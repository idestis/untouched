import { Logo } from "../components/Logo.jsx";

export function Footer() {
  return (
    <footer className="relative border-t border-white/5 py-12">
      <div className="mx-auto flex max-w-[1120px] flex-col items-center gap-6 px-6 text-center md:flex-row md:justify-between md:text-left">
        <div className="flex items-center gap-3">
          <Logo size={24} />
          <span
            className="text-[11px] font-medium uppercase text-ut-text-faint"
            style={{ letterSpacing: "0.3em" }}
          >
            Untouched
          </span>
        </div>

        <div className="flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-[12px] text-ut-text-faint">
          <a href="#manifesto" className="transition-colors hover:text-white">
            Manifesto
          </a>
          <a href="#coins" className="transition-colors hover:text-white">
            Coins
          </a>
          <a href="#pricing" className="transition-colors hover:text-white">
            Pricing
          </a>
          <a
            href="https://getunbroken.app"
            className="transition-colors hover:text-white"
          >
            Unbroken
          </a>
          <a
            href="/privacy.html"
            className="transition-colors hover:text-white"
          >
            Privacy
          </a>
        </div>

        <div className="text-[11px] text-ut-text-faint">getuntouched.app</div>
      </div>
    </footer>
  );
}
