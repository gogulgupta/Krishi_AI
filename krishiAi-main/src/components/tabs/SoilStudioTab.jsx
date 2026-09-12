import React from 'react';

export default function SoilStudioTab() {
  return (
    <div className="w-full h-[calc(100vh-64px)] min-h-[850px] p-0 m-0 overflow-hidden bg-slate-950">
      <iframe
        src="http://localhost:8501/?embed=true"
        title="Soil Classification Streamlit App"
        className="w-full h-full border-0 m-0 p-0 block bg-slate-950"
        allow="camera; microphone; geolocation; clipboard-read; clipboard-write"
        loading="eager"
      />
    </div>
  );
}
