export function LandingFooter() {
  const year = new Date().getFullYear();
  return (
    <footer className="border-t border-mist px-6 py-10">
      <div className="mx-auto flex max-w-6xl flex-col gap-6 text-sm text-stone md:flex-row md:items-center md:justify-between">
        <p className="font-display text-lg tracking-[0.08em] text-ink">byrous</p>
        <p>© {year} — vitrina inicial. Sistema en construcción.</p>
        <a href="/api/health" className="underline underline-offset-4 hover:text-ink">
          Estado del servicio
        </a>
      </div>
    </footer>
  );
}
