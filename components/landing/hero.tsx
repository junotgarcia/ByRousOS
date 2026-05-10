import Link from "next/link";

import { getInstagramUrl } from "@/config/site";

const instagramUrl = getInstagramUrl();

export function Hero() {
  return (
    <section
      id="vitrina"
      className="relative overflow-hidden px-6 pb-24 pt-16 md:pb-32 md:pt-24 lg:pb-36"
    >
      <div
        className="pointer-events-none absolute -right-24 top-0 h-[480px] w-[480px] rounded-full blur-3xl md:h-[620px] md:w-[620px]"
        aria-hidden
        style={{
          background:
            "radial-gradient(circle at 40% 40%, rgba(139,115,85,0.18), transparent 55%)",
        }}
      />

      <div className="relative mx-auto max-w-6xl">
        <p className="mb-6 text-[11px] font-medium uppercase tracking-[0.35em] text-stone">
          lifestyle · editorial · proceso consciente
        </p>
        <h1 className="font-display max-w-3xl text-5xl font-light leading-[1.06] md:text-6xl lg:text-[4.25rem]">
          Una vitrina que respira antes de escalar — piezas seleccionadas, ritmo
          editorial.
        </h1>
        <p className="mt-8 max-w-xl text-base leading-relaxed text-stone md:text-lg">
          Operamos desde una base moderna pensada para crecer: esta página marca el inicio
          del sistema; inventario, relación con personas y automatización llegan después,
          cuando el relato ya está claro.
        </p>
        <div className="mt-12 flex flex-wrap items-center gap-4">
          <a
            href={instagramUrl}
            target="_blank"
            rel="noreferrer"
            className="inline-flex h-12 items-center justify-center border border-ink bg-ink px-8 text-sm font-medium text-paper transition hover:bg-ink/90"
          >
            Ver en Instagram
          </a>
          <Link
            href="#senales"
            className="inline-flex h-12 items-center justify-center border border-mist bg-transparent px-8 text-sm font-medium text-ink transition hover:border-ink/40"
          >
            Qué viene
          </Link>
        </div>
      </div>
    </section>
  );
}
