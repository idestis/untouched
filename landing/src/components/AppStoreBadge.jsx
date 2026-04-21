export const APP_STORE_URL = "#";

export function AppStoreBadge({ href = APP_STORE_URL, className = "" }) {
  return (
    <a
      href={href}
      className={
        "inline-flex items-center gap-3 rounded-full bg-white px-5 py-3 text-black " +
        "transition-transform duration-300 ease-out hover:-translate-y-0.5 " +
        className
      }
    >
      <svg width="22" height="22" viewBox="0 0 384 512" fill="currentColor">
        <path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zM256.6 116.5C288.5 78.4 285.6 43.7 284.6 32c-28.8 1.7-62.1 19.6-81.1 41.6-20.9 23.5-33.2 52.6-30.6 85.1 31.2 2.4 59.6-13.7 83.7-42.2z" />
      </svg>
      <span className="flex flex-col leading-tight text-left">
        <span className="text-[10px] tracking-[0.15em] uppercase opacity-70">
          Download on the
        </span>
        <span className="text-[16px] font-medium tracking-tight">
          App Store
        </span>
      </span>
    </a>
  );
}
