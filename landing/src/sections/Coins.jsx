import { CoinRing } from "../components/CoinRing.jsx";

const MILESTONES = [
  { value: "1", label: "24 hours", day: 1 },
  { value: "7", label: "One week", day: 7 },
  { value: "30", label: "Thirty days", day: 30 },
  { value: "60", label: "Sixty days", day: 60 },
  { value: "90", label: "Ninety days", day: 90 },
  { value: "180", label: "Six months", day: 180 },
  { value: "270", label: "Nine months", day: 270 },
  { value: "365", label: "One year", day: 365 },
];

export function Coins() {
  return (
    <section
      id="coins"
      data-snap
      className="relative flex min-h-[100svh] flex-col justify-center overflow-hidden py-16 md:py-28"
    >
      <div aria-hidden className="amber-halo opacity-40" />

      <div className="relative mx-auto max-w-[1120px] px-6">
        <div className="mb-10 text-center md:mb-16">
          <span
            className="text-[10px] font-medium uppercase text-ut-text-faint"
            style={{ letterSpacing: "0.3em" }}
          >
            Coins
          </span>
          <h2 className="mt-3 text-[28px] font-medium leading-[1.1] tracking-[-0.02em] md:mt-4 md:text-[52px] md:leading-[1.05]">
            Earn them once.
            <br />
            <span className="text-ut-text-faint">Keep them forever.</span>
          </h2>
          <p className="mx-auto mt-6 max-w-[560px] text-[14px] leading-[1.6] text-ut-text-dim md:text-[15px]">
            Milestones earn you a coin. A slip resets the count &mdash; but the
            coins on your shelf are yours to keep. They record something that
            actually happened.
          </p>
        </div>

        <div className="grid grid-cols-4 gap-6 md:grid-cols-8 md:gap-4">
          {MILESTONES.map((m, i) => (
            <div key={m.day} className="flex flex-col items-center">
              <CoinRing value={m.value} size={i < 4 ? "md" : "md"} earned />
              <span className="mt-3 text-center text-[10px] font-medium uppercase text-ut-text-faint" style={{ letterSpacing: "0.2em" }}>
                {m.label}
              </span>
            </div>
          ))}
        </div>

        <div className="mt-12 text-center text-[12px] italic text-ut-text-faint md:mt-16">
          After one year, one coin per year, forever.
        </div>
      </div>
    </section>
  );
}
