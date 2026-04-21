export function Logo({ size = 28, className = "" }) {
  return (
    <img
      src="/logo.png"
      alt=""
      width={size}
      height={size}
      className={className}
      style={{ display: "block" }}
    />
  );
}

export function Wordmark({ className = "" }) {
  return (
    <span
      className={
        "font-medium tracking-[0.4em] text-[11px] uppercase " + className
      }
    >
      Untouched
    </span>
  );
}
