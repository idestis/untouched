import { AppStoreBadge } from "../components/AppStoreBadge.jsx";

export function Pricing() {
  return (
    <section
      id="pricing"
      data-snap
      className="relative flex min-h-[100svh] flex-col justify-center py-16 md:py-28"
    >
      <div className="mx-auto max-w-[720px] px-6">
        <div className="mb-8 text-center md:mb-12">
          <span
            className="text-[10px] font-medium uppercase text-ut-text-faint"
            style={{ letterSpacing: "0.3em" }}
          >
            Pricing
          </span>
          <h2 className="mt-4 text-[30px] font-medium leading-[1.1] tracking-[-0.02em] md:text-[52px] md:leading-[1.05]">
            One counter. <span className="text-ut-text-faint">Free.</span>
            <br />
            Three for $4.99 once.
          </h2>
        </div>

        <div className="rounded-[16px] bg-ut-surface p-6 hairline md:p-10">
          <dl className="flex flex-col gap-4 md:gap-5">
            <Row emphasis left="One counter, all features" right="Free" />
            <Divider />
            <Row
              emphasis
              left="Up to three counters, forever"
              right={
                <>
                  <span className="text-ut-amber">$4.99</span>
                  <span className="text-ut-text-faint"> · once</span>
                </>
              }
            />
          </dl>

          <dl className="mt-5 flex flex-col gap-2.5 border-t border-white/5 pt-5 md:mt-6 md:gap-3 md:pt-6">
            <Row left="Subscription" right={<Muted>Never</Muted>} />
            <Row left="Account" right={<Muted>None</Muted>} />
            <Row left="Family Sharing" right="Enabled" />
            <Row left="Restore on device" right="One tap" />
          </dl>

          <div className="mt-7 flex flex-col items-center border-t border-white/5 pt-7 md:mt-10 md:pt-8">
            <AppStoreBadge />
            <p className="mt-4 text-center text-[12px] text-ut-text-faint md:mt-5">
              One payment. No renewal. No upsell.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}

function Row({ left, right, emphasis }) {
  return (
    <div className="flex items-baseline justify-between gap-4">
      <dt
        className={
          emphasis
            ? "text-[14px] text-ut-text-dim md:text-[15px]"
            : "text-[13px] text-ut-text-dim md:text-[14px]"
        }
      >
        {left}
      </dt>
      <dd
        className={
          emphasis
            ? "text-right text-[16px] font-medium tabular-nums text-white md:text-[17px]"
            : "text-right text-[13px] font-medium tabular-nums text-white md:text-[14px]"
        }
      >
        {right}
      </dd>
    </div>
  );
}

function Divider() {
  return <div className="h-px w-full bg-white/5" />;
}

function Muted({ children }) {
  return <span className="text-ut-text-faint">{children}</span>;
}
