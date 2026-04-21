import { Logo } from "../components/Logo.jsx";
import { AppStoreBadge } from "../components/AppStoreBadge.jsx";

export function Hero() {
  return (
    <section
      data-snap
      className="relative flex min-h-[100svh] flex-col justify-center overflow-hidden pt-24 pb-16 md:pt-32 md:pb-20"
    >
      <div
        aria-hidden
        className="pointer-events-none absolute left-1/2 top-[-30%] h-[800px] w-[800px] -translate-x-1/2 rounded-full opacity-[0.07]"
        style={{
          background: "radial-gradient(circle, #EF9F27 0%, transparent 60%)",
          filter: "blur(40px)",
        }}
      />

      <div className="relative mx-auto max-w-[1120px] px-6">
        <div className="flex flex-col items-center text-center">
          <div className="fade-up">
            <Logo size={96} className="opacity-95" />
          </div>

          <div className="fade-up fade-up-delay-1 mt-8">
            <span
              className="text-[11px] font-medium uppercase text-ut-text-faint"
              style={{ letterSpacing: "0.45em" }}
            >
              Untouched
            </span>
          </div>

          <h1
            className="fade-up fade-up-delay-2 mt-10 max-w-[900px] font-medium leading-[1.02]"
            style={{
              fontSize: "clamp(44px, 8vw, 88px)",
              letterSpacing: "clamp(-1px, -0.5vw, -4px)",
            }}
          >
            Name one thing.
            <br />
            Step away from it.
            <br />
            <span className="text-ut-text-faint">Start over if you slip.</span>
          </h1>

          <p className="fade-up fade-up-delay-3 mt-10 max-w-[520px] text-[15px] leading-[1.6] text-ut-text-dim">
            We won&rsquo;t check. You will. The count is just for you.
          </p>

          <div className="fade-up fade-up-delay-3 mt-12 flex flex-col items-center gap-5 sm:flex-row sm:gap-4">
            <AppStoreBadge />
            <a
              href="#manifesto"
              className="text-[13px] text-ut-text-dim transition-colors hover:text-white"
            >
              Read the manifesto &rarr;
            </a>
          </div>

          <div className="fade-up fade-up-delay-3 mt-14 flex items-center gap-3 text-[11px] text-ut-text-faint">
            <span>iOS 17+</span>
            <span className="opacity-50">·</span>
            <span>No accounts</span>
            <span className="opacity-50">·</span>
            <span>No subscription</span>
            <span className="opacity-50">·</span>
            <span>Private by default</span>
          </div>
        </div>
      </div>
    </section>
  );
}
