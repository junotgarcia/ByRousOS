const highlights = [
  {
    title: "Curaduría",
    body: "Menos ruido, más intención. La vitrina refleja el tono de la marca.",
  },
  {
    title: "Editorial",
    body: "Historias y campañas en Instagram como canal principal hoy.",
  },
  {
    title: "Sistema",
    body: "La web conecta con un núcleo que podrá orquestar stock, clientes y datos.",
  },
];

export function EditorialStrip() {
  return (
    <section className="border-y border-mist bg-white/40 px-6 py-20">
      <div className="mx-auto grid max-w-6xl gap-12 md:grid-cols-3 md:gap-10">
        {highlights.map((item) => (
          <div key={item.title} className="space-y-3">
            <h2 className="font-display text-2xl font-light text-ink">{item.title}</h2>
            <p className="text-sm leading-relaxed text-stone">{item.body}</p>
          </div>
        ))}
      </div>
    </section>
  );
}
