const PRINCIPLES = [
  {
    n: "01",
    title: "One thing.",
    body: "You name it. Privately. The app never asks what it is, never suggests a category, never assumes.",
  },
  {
    n: "02",
    title: "No verification.",
    body: "No camera. No location. No pulse. The app trusts you completely. If you lie, you lie to yourself &mdash; and you know it.",
  },
  {
    n: "03",
    title: "Days go up.",
    body: "Never down. No countdown timers. No pressure framing. Just the number since the last time you slipped.",
  },
  {
    n: "04",
    title: "Coins stay.",
    body: "Every milestone earns a coin. A slip resets the count. The coin stays on the shelf. Forever.",
  },
  {
    n: "05",
    title: "Reset requires typing.",
    body: "One sentence. Five characters minimum. Stored encrypted. Never shown again unless you ask. Friction protects honesty.",
  },
  {
    n: "06",
    title: "No community.",
    body: "No feed. No leaderboards. No friends. No anonymous group. The share card is a one-way private export, or nothing at all.",
  },
  {
    n: "07",
    title: "No moralizing.",
    body: "The app never says relapse, failure, fall, or ashamed. It counts days. That&rsquo;s the whole contract.",
  },
  {
    n: "08",
    title: "Widget-first.",
    body: "The lock-screen widget is the primary surface. Opening the app should be optional, not habitual.",
  },
];

export function Manifesto() {
  return (
    <section
      id="manifesto"
      data-snap
      className="relative flex min-h-[100svh] flex-col justify-center py-12 md:py-28"
    >
      <div className="mx-auto max-w-[1080px] px-6">
        <div className="mb-8 text-center md:mb-14">
          <span
            className="text-[10px] font-medium uppercase text-ut-text-faint"
            style={{ letterSpacing: "0.3em" }}
          >
            Manifesto
          </span>
          <h2 className="mt-3 text-[24px] font-medium leading-[1.15] tracking-[-0.02em] md:mt-4 md:text-[44px] md:leading-[1.1]">
            A counter, not a coach.
          </h2>
        </div>

        <div className="grid gap-3 md:grid-cols-2 md:gap-4">
          {PRINCIPLES.map((p) => (
            <PrincipleCard key={p.n} {...p} />
          ))}
        </div>

        <div className="mt-8 text-center text-[13px] italic text-ut-text-faint md:mt-16">
          &ldquo;The count belongs to you. Nobody else.&rdquo;
        </div>
      </div>
    </section>
  );
}

function PrincipleCard({ n, title, body }) {
  return (
    <div className="relative rounded-[16px] bg-ut-surface p-5 hairline md:p-7">
      <div
        className="mb-4 text-[11px] font-medium text-ut-amber md:mb-8"
        style={{ letterSpacing: "0.3em" }}
      >
        {n}
      </div>
      <div className="mb-2 text-[20px] font-medium tracking-[-0.02em] md:mb-3 md:text-[22px]">
        {title}
      </div>
      <p
        className="text-[14px] leading-[1.55] text-ut-text-dim md:leading-[1.6]"
        dangerouslySetInnerHTML={{ __html: body }}
      />
    </div>
  );
}
