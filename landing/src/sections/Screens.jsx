import { useEffect, useRef, useState } from "preact/hooks";
import { Phone } from "../components/Phone.jsx";

const SCREENS = [
  {
    id: "manifesto",
    label: "Manifesto",
    caption: "The first screen. The last negotiation.",
  },
  {
    id: "name-it",
    label: "Name it",
    caption: "Type the word. Pick a date. Begin.",
  },
  {
    id: "today",
    label: "Today",
    caption: "The big number. Yesterday&rsquo;s truth. Nothing else.",
  },
  {
    id: "coin-earned",
    label: "Coin earned",
    caption: "A milestone. A ring. An optional engraving.",
  },
  {
    id: "shelf",
    label: "Shelf",
    caption: "Every coin you&rsquo;ve earned. The locked ones come next.",
  },
  {
    id: "reset",
    label: "Reset",
    caption: "One typed sentence. The shelf stays. The count goes to zero.",
  },
  {
    id: "widget",
    label: "Widget",
    caption: "The primary surface. Opening the app is optional.",
  },
];

const ADVANCE_MS = 3200;

export function Screens() {
  const sectionRef = useRef(null);
  const [active, setActive] = useState(0);
  const [inView, setInView] = useState(false);

  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      ([entry]) =>
        setInView(entry.isIntersecting && entry.intersectionRatio >= 0.55),
      { threshold: [0, 0.55, 1] }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, []);

  useEffect(() => {
    if (!inView) return;
    const id = window.setInterval(() => {
      setActive((i) => (i + 1) % SCREENS.length);
    }, ADVANCE_MS);
    return () => window.clearInterval(id);
  }, [inView, active]);

  const current = SCREENS[active];

  return (
    <section
      ref={sectionRef}
      id="screens"
      data-snap
      className="relative flex min-h-[100svh] flex-col justify-center overflow-hidden py-12 md:py-20"
    >
      <div className="mx-auto w-full max-w-[1180px] px-6">
        <div className="mb-6 text-center md:mb-16">
          <span
            className="text-[10px] font-medium uppercase text-ut-text-faint"
            style={{ letterSpacing: "0.3em" }}
          >
            Seven screens
          </span>
          <h2 className="mt-3 text-[24px] font-medium leading-[1.15] tracking-[-0.02em] md:mt-4 md:text-[44px] md:leading-[1.1]">
            That&rsquo;s the whole app.
          </h2>
        </div>

        <div className="flex flex-col items-center gap-6 sm:flex-row sm:items-center sm:justify-center sm:gap-8 lg:gap-16">
          <ol className="order-2 flex flex-row flex-nowrap justify-center gap-0 sm:order-1 sm:flex-col sm:items-stretch sm:gap-1">
            {SCREENS.map((s, i) => {
              const isActive = i === active;
              return (
                <li key={s.id} className="flex">
                  <button
                    type="button"
                    onClick={() => setActive(i)}
                    className={
                      "group relative flex w-full items-center gap-2 rounded-[12px] px-1.5 py-2.5 transition-colors sm:gap-3 sm:justify-end sm:px-3 sm:py-3 " +
                      (isActive
                        ? "text-white"
                        : "text-ut-text-faint hover:text-ut-text-dim")
                    }
                  >
                    <span className="hidden text-[14px] font-medium tracking-[-0.01em] transition-colors sm:inline">
                      {s.label}
                    </span>
                    <span
                      className="text-[10px] font-medium uppercase tabular-nums"
                      style={{ letterSpacing: "0.25em" }}
                    >
                      {String(i + 1).padStart(2, "0")}
                    </span>
                    <span
                      aria-hidden
                      className={
                        "h-px transition-all duration-500 " +
                        (isActive
                          ? "w-6 bg-ut-amber sm:w-14"
                          : "w-3 bg-white/15 sm:w-6")
                      }
                    />
                  </button>
                </li>
              );
            })}
          </ol>

          <div className="order-1 flex flex-col items-center sm:order-2">
            <div className="mb-4 sm:hidden">
              <span
                key={current.id + "-label"}
                className="fade-up text-[11px] font-medium uppercase text-white"
                style={{ letterSpacing: "0.35em" }}
              >
                {current.label}
              </span>
            </div>
            <div className="relative w-full max-w-[220px] sm:max-w-[240px] md:max-w-[260px]">
              {SCREENS.map((s, i) => (
                <div
                  key={s.id}
                  aria-hidden={i !== active}
                  className={
                    "transition-opacity duration-500 " +
                    (i === active
                      ? "relative opacity-100"
                      : "pointer-events-none absolute inset-0 opacity-0")
                  }
                >
                  <Phone src={`/screens/${s.id}-dark.png`} alt={s.label} />
                </div>
              ))}
            </div>

            <div className="mt-4 h-12 max-w-[320px] text-center md:mt-6">
              <p
                key={current.id}
                className="fade-up text-[13px] leading-[1.55] text-ut-text-dim"
                dangerouslySetInnerHTML={{ __html: current.caption }}
              />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
