export function Phone({ src, alt = "", light = false, className = "", children }) {
  const frame = light ? "phone-frame-light" : "phone-frame";

  return (
    <div className={frame + " " + className}>
      {children ? (
        <div className="phone-screen" style={{ background: light ? "#f7f3ea" : "#000" }}>
          {children}
        </div>
      ) : src ? (
        <img
          src={src}
          alt={alt}
          className="phone-screen"
          loading="lazy"
          decoding="async"
        />
      ) : (
        <PhoneSkeleton light={light} />
      )}
    </div>
  );
}

function PhoneSkeleton({ light }) {
  const bg = light ? "#f7f3ea" : "#000000";
  const border = light ? "rgba(0,0,0,0.08)" : "rgba(255,255,255,0.06)";
  const text = light ? "rgba(0,0,0,0.35)" : "rgba(255,255,255,0.35)";

  return (
    <div
      className="phone-screen flex flex-col items-center justify-center gap-3 px-6"
      style={{
        background: bg,
        border: `0.5px solid ${border}`,
      }}
    >
      <div
        style={{
          letterSpacing: "0.4em",
          fontSize: "10px",
          color: text,
          textTransform: "uppercase",
          fontWeight: 500,
        }}
      >
        Untouched
      </div>
      <div
        style={{
          fontSize: "11px",
          color: text,
          textAlign: "center",
          lineHeight: 1.5,
          maxWidth: "70%",
        }}
      >
        Drop a simulator screenshot in
        <br />
        <code style={{ fontSize: "10px" }}>public/screens/</code>
      </div>
    </div>
  );
}
