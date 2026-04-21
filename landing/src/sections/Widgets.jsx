export function Widgets() {
  return (
    <section
      id="widgets"
      data-snap
      className="relative flex min-h-[100svh] flex-col justify-center py-16 md:py-28"
    >
      <div className="mx-auto max-w-[1120px] px-6">
        <div className="mb-10 text-center md:mb-16">
          <span
            className="text-[10px] font-medium uppercase text-ut-text-faint"
            style={{ letterSpacing: "0.3em" }}
          >
            Widgets
          </span>
          <h2 className="mt-3 text-[28px] font-medium leading-[1.1] tracking-[-0.02em] md:mt-4 md:text-[52px] md:leading-[1.05]">
            The app is optional.
            <br />
            <span className="text-ut-text-faint">The count isn&rsquo;t.</span>
          </h2>
          <p className="mx-auto mt-6 max-w-[560px] text-[14px] leading-[1.6] text-ut-text-dim md:text-[15px]">
            The widget is the primary surface. Look at your lock screen. See
            the number. Go back to your life.
          </p>
        </div>

        <div className="grid gap-4 md:grid-cols-3">
          <WidgetCard label="Lock screen — inline">
            <div className="flex justify-center py-6">
              <span className="widget-mock-inline">
                <CoinDot />
                47 days untouched
              </span>
            </div>
          </WidgetCard>

          <WidgetCard label="Lock screen — rectangular">
            <div className="widget-mock flex flex-col gap-1">
              <span
                className="text-[9px] font-medium uppercase text-white/50"
                style={{ letterSpacing: "0.25em" }}
              >
                Untouched
              </span>
              <span className="text-[26px] font-medium leading-none tracking-[-1px]">
                47
              </span>
              <span className="text-[10px] text-white/60">
                13 days until next coin
              </span>
            </div>
          </WidgetCard>

          <WidgetCard label="Home screen — medium">
            <div className="widget-mock flex flex-col gap-2">
              <span
                className="text-[9px] font-medium uppercase text-ut-amber"
                style={{ letterSpacing: "0.25em" }}
              >
                Cigarettes.
              </span>
              <div className="flex items-baseline gap-2">
                <span className="text-[44px] font-medium leading-none tracking-[-2px]">
                  47
                </span>
                <span className="text-[11px] text-white/60">days</span>
              </div>
              <div className="mt-1 h-1 w-full overflow-hidden rounded-full bg-white/10">
                <div
                  className="h-full rounded-full"
                  style={{
                    width: "78%",
                    background: "var(--color-ut-amber)",
                  }}
                />
              </div>
              <div className="mt-1 flex items-center justify-between text-[9px] text-white/50">
                <span>30d</span>
                <span>60d</span>
              </div>
            </div>
          </WidgetCard>
        </div>
      </div>
    </section>
  );
}

function WidgetCard({ label, children }) {
  return (
    <div className="rounded-[16px] bg-ut-surface p-5 hairline md:p-6">
      <span
        className="text-[10px] font-medium uppercase text-ut-text-faint"
        style={{ letterSpacing: "0.3em" }}
      >
        {label}
      </span>
      <div className="mt-4">{children}</div>
    </div>
  );
}

function CoinDot() {
  return (
    <span
      style={{
        width: 10,
        height: 10,
        borderRadius: "50%",
        background: "var(--color-ut-amber)",
        boxShadow: "0 0 12px var(--color-ut-amber-glow)",
      }}
    />
  );
}
