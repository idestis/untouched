import { Logo } from "../components/Logo.jsx";

export function Nav() {
  return (
    <header className="fixed inset-x-0 top-0 z-50 backdrop-blur-xl">
      <div className="absolute inset-0 bg-black/60" />
      <div className="absolute inset-x-0 bottom-0 h-px bg-white/5" />
      <div className="relative mx-auto flex max-w-[1280px] items-center justify-between px-6 py-4">
        <a href="#" className="flex items-center gap-3">
          <Logo size={26} />
          <span
            className="text-[11px] font-medium uppercase text-white"
            style={{ letterSpacing: "0.4em" }}
          >
            Untouched
          </span>
        </a>

        <nav className="flex items-center gap-5 text-[12px] text-ut-text-dim md:gap-8">
          <a
            href="#manifesto"
            className="hidden transition-colors hover:text-white md:inline"
          >
            Manifesto
          </a>
          <a
            href="#coins"
            className="hidden transition-colors hover:text-white md:inline"
          >
            Coins
          </a>
          <a
            href="#pricing"
            className="hidden transition-colors hover:text-white md:inline"
          >
            Pricing
          </a>
          <a
            href="#"
            className="rounded-full bg-white px-3.5 py-1.5 text-[12px] font-medium text-black transition-transform duration-300 ease-out hover:-translate-y-0.5 md:px-4 md:py-2"
          >
            Get the app
          </a>
        </nav>
      </div>
    </header>
  );
}
