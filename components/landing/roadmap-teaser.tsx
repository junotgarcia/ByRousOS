const pillars = [
  "Inventario y catálogo",
  "CRM y segmentos",
  "Paneles y decisiones",
  "Automatización operativa",
  "Comercio electrónico",
];

export function RoadmapTeaser() {
  return (
    <section id="senales" className="px-6 py-24 md:py-28">
      <div className="mx-auto max-w-6xl">
        <div className="grid gap-14 lg:grid-cols-[1fr,1.1fr] lg:items-start">
          <div>
            <p className="text-[11px] font-medium uppercase tracking-[0.35em] text-stone">
              hoja de ruta
            </p>
            <h2 className="mt-4 font-display text-4xl font-light md:text-5xl">
              De vitrina a sistema operativo.
            </h2>
            <p className="mt-6 max-w-md text-base leading-relaxed text-stone">
              Cada bloque puede activarse cuando el negocio lo pida — la arquitectura ya
              separa superficie web, datos y automatización para que incorporar IA sea
              natural (asistentes internos, resúmenes, routing de consultas).
            </p>
          </div>

          <ul className="space-y-0 divide-y divide-mist border-y border-mist">
            {pillars.map((label, idx) => (
              <li
                key={label}
                className="flex items-center justify-between gap-6 py-5 text-sm text-ink md:text-[15px]"
              >
                <span className="font-medium">{label}</span>
                <span className="shrink-0 text-xs uppercase tracking-widest text-stone">
                  fase {idx + 1}
                </span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
}
