import { Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import Home from './pages/Home';
import Visualisations from './pages/Visualisations';
import Predictions from './pages/Predictions';
import DataExplorer from './pages/DataExplorer';
import HelpAccessibility from './pages/HelpAccessibility';


function App() {
  return (
    <div className="app-wrapper">
      <Navbar />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/visualisations" element={<Visualisations />} /> 
        <Route path="/predictions" element={<Predictions />} />
        <Route path="/explorer" element={<DataExplorer />} />
        <Route path="/aide" element={< HelpAccessibility/>} />
      </Routes>
      <Footer />
    </div>
  );
}

export default App;
