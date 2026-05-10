import type { Metadata } from "next";
import { Cormorant_Garamond, Figtree } from "next/font/google";

import "./globals.css";
import { SITE } from "@/config/site";

const display = Cormorant_Garamond({
  subsets: ["latin"],
  variable: "--font-cormorant",
  display: "swap",
});

const sans = Figtree({
  subsets: ["latin"],
  variable: "--font-figtree",
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: `${SITE.name} — Lifestyle & fashion`,
    template: `%s · ${SITE.name}`,
  },
  description:
    "Marca lifestyle y fashion. Explora la vitrina, historias en Instagram y lo que viene.",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="es">
      <body
        className={`${sans.variable} ${display.variable} min-h-dvh bg-paper text-ink`}
      >
        {children}
      </body>
    </html>
  );
}
