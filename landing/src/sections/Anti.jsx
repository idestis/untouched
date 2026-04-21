const HAS = [
  "One counter on free, up to three on $4.99",
  "Milestone coins from 24h to yearly, forever",
  "Lock-screen and home-screen widgets",
  "Optional daily check-in, one a day at most",
  "Typed reset, encrypted locally",
  "Dark-first, true OLED black with amber accents",
];

const HAS_NOT = [
  "Verification, proof, or check-in photos",
  "AI sponsor, chatbot, or coach",
  "Feed, friends, leaderboards, or community",
  "Streak freezes or recovery purchases",
  "Accounts, cloud sync, or analytics",
  "Moralizing copy &mdash; no relapse, failure, or shame",
];

export function Anti() {
  return (
    <section
      data-snap
      className="relative flex min-h-[100svh] flex-col justify-center py-12 md:py-28"
    >
      <div className="mx-auto max-w-[1120px] px-6">
        <div className="mb-8 text-center md:mb-16">
          <span
            className="text-[10px] font-medium uppercase text-ut-text-faint"
            style={{ letterSpacing: "0.3em" }}
          >
            What it is, what it isn&rsquo;t
          </span>
          <h2 className="mt-4 max-w-[720px] mx-auto text-[26px] font-medium leading-[1.15] tracking-[-0.02em] md:text-[44px] md:leading-[1.1]">
            A witness, not a coach.
            <span className="text-ut-text-faint"> No sponsor. No feed.</span>
          </h2>
        </div>

        <div className="grid gap-3 md:grid-cols-2 md:gap-6">
          <List kind="has" label="What&rsquo;s in" items={HAS} />
          <List kind="hasnot" label="What&rsquo;s never in" items={HAS_NOT} />
        </div>
      </div>
    </section>
  );
}

function List({ kind, label, items }) {
  const isHas = kind === "has";
  return (
    <div className="rounded-[16px] bg-ut-surface p-5 hairline md:p-8">
      <div
        className="mb-4 text-[10px] font-medium uppercase md:mb-6"
        style={{
          letterSpacing: "0.3em",
          color: isHas ? "#EF9F27" : "#E24B4A",
          opacity: 0.8,
        }}
        dangerouslySetInnerHTML={{ __html: label }}
      />
      <ul className="flex flex-col gap-3 md:gap-4">
        {items.map((item) => (
          <li
            key={item}
            className="flex items-start gap-3 md:gap-4"
          >
            {isHas ? <Check /> : <Cross />}
            <span
              className={
                isHas
                  ? "text-[14px] text-white md:text-[15px]"
                  : "text-[14px] text-white/70 md:text-[15px]"
              }
              dangerouslySetInnerHTML={{ __html: item }}
            />
          </li>
        ))}
      </ul>
    </div>
  );
}

function Check() {
  return (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="#EF9F27"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className="mt-1 flex-shrink-0"
    >
      <polyline points="20 6 9 17 4 12" />
    </svg>
  );
}

function Cross() {
  return (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="#E24B4A"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className="mt-1 flex-shrink-0 opacity-70"
    >
      <line x1="18" y1="6" x2="6" y2="18" />
      <line x1="6" y1="6" x2="18" y2="18" />
    </svg>
  );
}
