// Signature coin motif. Earned coins glow amber. Locked coins are dashed.
export function CoinRing({ value, label, size = "md", earned = true, className = "" }) {
  const sizeClass =
    size === "lg" ? "coin-ring-lg" : size === "sm" ? "coin-ring-sm" : "coin-ring-md";
  const base = earned ? "coin-ring" : "coin-ring-locked";

  return (
    <div className={"flex flex-col items-center gap-2 " + className}>
      <div className={base + " " + sizeClass}>
        <span>{value}</span>
      </div>
      {label && (
        <span
          className="text-[10px] font-medium uppercase"
          style={{
            letterSpacing: "0.25em",
            color: earned ? "var(--color-ut-amber)" : "var(--color-ut-text-faint)",
          }}
        >
          {label}
        </span>
      )}
    </div>
  );
}
