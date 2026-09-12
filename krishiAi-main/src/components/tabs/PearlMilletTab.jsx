import React from 'react';

export default function PearlMilletTab() {
  return (
    <div className="w-full h-[calc(100vh-64px)] min-h-[850px] p-0 m-0 overflow-hidden bg-slate-950">
      <iframe
        src="http://localhost:8502/?embed=true"
        title="Plant Disease Detector Streamlit App"
        className="w-full h-full border-0 m-0 p-0 block bg-slate-950"
        allow="camera; microphone; geolocation; clipboard-read; clipboard-write"
        loading="eager"
      />
    </div>
  );
}
