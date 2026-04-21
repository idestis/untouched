import { Nav } from "./sections/Nav.jsx";
import { Hero } from "./sections/Hero.jsx";
import { Manifesto } from "./sections/Manifesto.jsx";
import { Screens } from "./sections/Screens.jsx";
import { Coins } from "./sections/Coins.jsx";
import { Widgets } from "./sections/Widgets.jsx";
import { Anti } from "./sections/Anti.jsx";
import { Pricing } from "./sections/Pricing.jsx";
import { About } from "./sections/About.jsx";
import { Footer } from "./sections/Footer.jsx";

export default function App() {
  return (
    <div className="grain min-h-screen bg-ut-bg text-white">
      <Nav />
      <main>
        <Hero />
        <Manifesto />
        <Screens />
        <Coins />
        <Widgets />
        <Anti />
        <Pricing />
        <About />
      </main>
      <Footer />
    </div>
  );
}
