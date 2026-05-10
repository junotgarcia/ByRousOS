import Link from "next/link";

import { getInstagramUrl } from "@/config/site";

const instagramUrl = getInstagramUrl();

export function LandingNav() {
  return (
    <header className="sticky top-0 z-20 border-b border-mist/80 bg-paper/90 backdrop-blur-md">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-6">
        <Link
          href="/"
          className="font-display text-xl tracking-[0.12em] text-ink lowercase"
        >
          byrous
        </Link>
        <nav className="flex items-center gap-8 text-sm text-stone">
          <a href="#vitrina" className="transition hover:text-ink">
            Vitrina
          </a>
          <a href="#senales" className="transition hover:text-ink">
            Señales
          </a>
          <a
            href={instagramUrl}
            target="_blank"
            rel="noreferrer"
            className="transition hover:text-ink"
          >
            Instagram
          </a>
        </nav>
      </div>
    </header>
  );
}
