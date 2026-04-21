export function About() {
  return (
    <section
      data-snap
      className="relative flex min-h-[100svh] flex-col justify-center py-24 md:py-28"
    >
      <div className="mx-auto max-w-[720px] px-6">
        <div className="mb-12 text-center">
          <span
            className="text-[10px] font-medium uppercase text-ut-text-faint"
            style={{ letterSpacing: "0.3em" }}
          >
            Why this exists
          </span>
        </div>

        <div className="space-y-7 text-[17px] leading-[1.7] text-white">
          <p>
            Every app in this space asks you to name the thing.
            <em> Alcohol. Nicotine. Someone.</em> Then it puts you in a group
            and calls you a category.
          </p>
          <p className="text-ut-text-dim">
            I didn&rsquo;t want that. I wanted a number on my lock screen that
            I could check without narrating my life to a server.
          </p>
          <p className="text-ut-text-dim">
            So Untouched does one thing. You type the word. The app counts
            days. When you earn a coin, it shows up on the shelf. When you
            slip, you type what happened, hit reset, and the count goes back
            to zero. The coins stay.
          </p>
          <p className="text-ut-text-dim">
            No sponsor. No sync. No category. No check-in. The word you type
            never leaves the phone.
          </p>
          <p>
            Sibling app to{" "}
            <a
              href="https://getunbroken.app"
              className="underline decoration-ut-amber/40 underline-offset-4 transition-colors hover:text-ut-amber"
            >
              Unbroken
            </a>
            . Same house, different grip.
          </p>
        </div>

        <div className="mt-14 text-[13px] text-ut-text-faint">
          &mdash; Dmytro
        </div>
      </div>
    </section>
  );
}
