export const SITE = {
  name: "ByRous",
  defaultLocale: "es",
  contactEmail: "",
} as const;

/** Safe for Client Components — only `NEXT_PUBLIC_*` vars. */
export function getInstagramUrl() {
  const url = process.env.NEXT_PUBLIC_INSTAGRAM_URL;
  if (url && /^https?:\/\//i.test(url)) return url;
  return "https://instagram.com";
}
