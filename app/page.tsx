import { LandingFooter } from "@/components/landing/landing-footer";
import { LandingNav } from "@/components/landing/landing-nav";
import { EditorialStrip } from "@/components/landing/editorial-strip";
import { Hero } from "@/components/landing/hero";
import { RoadmapTeaser } from "@/components/landing/roadmap-teaser";

export default function HomePage() {
  return (
    <div className="relative flex min-h-dvh flex-col">
      <LandingNav />
      <main className="flex-1">
        <Hero />
        <EditorialStrip />
        <RoadmapTeaser />
      </main>
      <LandingFooter />
    </div>
  );
}
