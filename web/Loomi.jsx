import React, { useState, useEffect, useRef } from "react";

/*
  Loomi — a pocket calm companion for stressful days.
  Palette + character derived from the uploaded Doberman puppy artwork:
    navy body, caramel tan points, dusty-rose backdrop, red collar, gold tag.
  Core idea (a stress-focused riff on Rootd): one big button you press when
  things feel heavy, and Loomi walks you through breathing, grounding, and
  unpacking the stressor — then learning sections + support resources.
*/

const STYLES = `
@import url('https://fonts.googleapis.com/css2?family=Nunito+Sans:wght@600;700;800&family=Inter:ital,wght@0,400;0,600;0,700;1,400&display=swap');

:root{
  /* Brand-board base colors (exact hex from the board) */
  --navy:#1D2E3D; --navy-deep:#1B2A38;
  --tan:#E5883C; --tan-light:#FAA559; --tan-dark:#C8712C;
  --rose-bg:#F4C5C3; --rose-soft:#FBD5D4; --rose-deep:#DC9B97;
  --red:#E12E2D; --red-deep:#C52323;
  --gold:#E6C542; --gold-deep:#CDAA33;
  --teal:#46AFB7; --teal-deep:#3E9AA1;
  --leaf-green:#A9D79F;
  --cream:#FBF4EF; --ink:#1D2E3D; --muted:#6E6258;
}
*{box-sizing:border-box}
.loomi-app{
  font-family:'Inter',system-ui,sans-serif;
  color:var(--ink);
  background:
    radial-gradient(120% 80% at 50% -10%, var(--rose-soft) 0%, var(--rose-bg) 55%, #EAC9C3 100%);
  min-height:100%;
  width:100%;
}
.loomi-wrap{ max-width:460px; margin:0 auto; padding:22px 20px 40px; }
.loomi-h{ font-family:'Nunito Sans',sans-serif; line-height:1.05; }
button{ font-family:'Nunito Sans',sans-serif; cursor:pointer; border:none; }
button:focus-visible, a:focus-visible{ outline:3px solid var(--red); outline-offset:3px; border-radius:14px; }

/* top bar */
.topbar{ display:flex; align-items:center; justify-content:space-between; margin-bottom:8px; }
.brandmark{ display:flex; align-items:center; gap:9px; }
.brandmark .dot{ width:30px; height:30px; border-radius:50%; background:var(--red);
  display:flex; align-items:center; justify-content:center; box-shadow:0 3px 0 var(--red-deep); }
.brandmark .dot span{ width:11px; height:11px; border-radius:50%; background:var(--gold); }
.brandname{ font-family:'Nunito Sans',sans-serif; font-weight:800; font-size:22px; letter-spacing:.3px; }
.help-pill{ background:var(--cream); color:var(--teal-deep); font-weight:700; font-size:13px;
  padding:7px 13px; border-radius:999px; box-shadow:0 2px 6px rgba(46,61,73,.12); }

/* cards */
.card{ background:var(--cream); border-radius:24px; padding:20px;
  box-shadow:0 10px 30px -12px rgba(46,61,73,.30); }
.eyebrow{ text-transform:uppercase; letter-spacing:2.5px; font-size:11px; font-weight:700;
  color:var(--tan-dark); font-family:'Inter'; }

/* home hero */
.hero{ text-align:center; padding-top:6px; }
.hero h1{ font-size:34px; font-weight:800; margin:14px 0 6px; }
.hero p.sub{ font-size:16px; color:var(--muted); margin:0 auto 4px; max-width:300px; line-height:1.45; }
.speech{ display:inline-block; background:var(--cream); border-radius:20px 20px 20px 6px;
  padding:12px 16px; font-size:15px; font-weight:600; color:var(--ink);
  box-shadow:0 6px 18px -8px rgba(46,61,73,.3); margin-bottom:6px; max-width:300px; }

/* big primary button */
.big-btn{ width:100%; background:var(--red); color:var(--cream); font-size:21px; font-weight:700;
  padding:20px; border-radius:22px; box-shadow:0 6px 0 var(--red-deep), 0 14px 26px -10px rgba(204,57,45,.6);
  transition:transform .08s ease, box-shadow .08s ease; margin-top:18px; }
.big-btn:active{ transform:translateY(4px); box-shadow:0 2px 0 var(--red-deep), 0 8px 16px -10px rgba(204,57,45,.6); }
.big-btn small{ display:block; font-size:13px; font-weight:600; opacity:.9; margin-top:2px; font-family:'Inter'; }

/* nav grid */
.nav-grid{ display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-top:14px; }
.nav-card{ background:var(--cream); border-radius:20px; padding:16px; text-align:left;
  box-shadow:0 6px 18px -10px rgba(46,61,73,.3); transition:transform .12s ease; }
.nav-card:active{ transform:scale(.97); }
.nav-card .ico{ font-size:22px; }
.nav-card .t{ font-family:'Nunito Sans',sans-serif; font-weight:700; font-size:16px; margin-top:6px; }
.nav-card .d{ font-size:12.5px; color:var(--muted); margin-top:2px; line-height:1.35; }

/* generic page */
.page-head{ display:flex; align-items:center; gap:12px; margin:4px 0 18px; }
.back{ background:var(--cream); width:42px; height:42px; border-radius:50%; font-size:20px;
  color:var(--ink); box-shadow:0 4px 12px -6px rgba(46,61,73,.4); display:flex; align-items:center; justify-content:center; flex:0 0 auto; }
.page-head h2{ font-size:24px; font-weight:800; }

.lesson{ margin-bottom:14px; }
.lesson .num{ font-family:'Nunito Sans'; font-weight:700; color:var(--red); }
.lesson h3{ font-family:'Nunito Sans'; font-weight:700; font-size:17px; margin:0 0 4px; }
.lesson p{ font-size:14.5px; color:var(--muted); line-height:1.5; margin:0; }

/* relief flow */
.flow{ text-align:center; }
.flow .line{ font-size:20px; font-weight:700; font-family:'Nunito Sans'; line-height:1.3; margin:16px 0 6px; }
.flow .hint{ font-size:14.5px; color:var(--muted); margin:0 auto 8px; max-width:320px; line-height:1.5; }
.choice{ width:100%; background:var(--cream); color:var(--ink); font-size:17px; font-weight:700;
  padding:16px; border-radius:18px; box-shadow:0 5px 16px -8px rgba(46,61,73,.35); margin-top:10px; }
.choice:active{ transform:scale(.98); }
.choice.alt{ background:var(--navy); color:var(--cream); }

/* breathing orb */
.orb-stage{ position:relative; width:240px; height:240px; margin:8px auto 4px; display:flex; align-items:center; justify-content:center; }
.orb{ position:absolute; width:170px; height:170px; border-radius:50%;
  background:radial-gradient(circle at 38% 32%, var(--rose-soft), var(--rose-deep));
  box-shadow:0 0 0 10px rgba(204,57,45,.10), 0 0 0 22px rgba(204,57,45,.05);
  display:flex; align-items:center; justify-content:center; }
.orb-ring{ position:absolute; width:170px; height:170px; border-radius:50%; border:4px solid var(--red); opacity:.55; }
.orb-label{ font-family:'Nunito Sans'; font-weight:700; color:var(--navy-deep); font-size:19px; text-align:center; }
.orb-label .cnt{ display:block; font-size:30px; }
.breath-meta{ font-size:14px; color:var(--muted); margin-top:2px; }

textarea.field{ width:100%; border:2px solid var(--rose-deep); border-radius:16px; padding:13px;
  font-family:'Inter'; font-size:15px; resize:vertical; min-height:84px; background:var(--cream); color:var(--ink); }
textarea.field:focus{ outline:none; border-color:var(--red); }

.row2{ display:flex; gap:10px; margin-top:12px; }
.row2 .choice{ margin-top:0; }

.ghost{ background:transparent; color:var(--muted); font-weight:700; font-size:14px; padding:10px; margin-top:10px; font-family:'Nunito Sans'; }
.dots{ display:flex; gap:7px; justify-content:center; margin:14px 0 2px; }
.dots i{ width:8px; height:8px; border-radius:50%; background:var(--rose-deep); display:block; }
.dots i.on{ background:var(--red); }

.note{ font-size:12.5px; color:var(--muted); line-height:1.5; }
.res{ background:var(--cream); border-radius:18px; padding:15px; margin-bottom:11px; box-shadow:0 5px 16px -10px rgba(46,61,73,.3);}
.res .rt{ font-family:'Nunito Sans'; font-weight:700; font-size:15.5px; }
.res .rd{ font-size:13.5px; color:var(--muted); margin-top:3px; line-height:1.45; }
.res a{ color:var(--red-deep); font-weight:700; text-decoration:none; }

/* puppy + animations */
.puppy{ display:block; }
.float{ animation:float 5s ease-in-out infinite; }
@keyframes float{ 0%,100%{ transform:translateY(0) } 50%{ transform:translateY(-9px) } }
.puppy .lid{ transform-box:fill-box; transform-origin:center; transform:scaleY(0); animation:blink 6s infinite; }
@keyframes blink{ 0%,93%,100%{ transform:scaleY(0) } 96%{ transform:scaleY(1) } }
.bounce{ animation:bounce .7s ease infinite; }
@keyframes bounce{ 0%,100%{ transform:translateY(0) } 30%{ transform:translateY(-12px) } 55%{ transform:translateY(0) } }
.sparkle{ animation:spark 1.4s ease-in-out infinite; transform-origin:center; }
@keyframes spark{ 0%,100%{ opacity:.3; transform:scale(.8) } 50%{ opacity:1; transform:scale(1.1) } }

@media (prefers-reduced-motion: reduce){
  .float,.bounce,.puppy .lid,.sparkle,.orb{ animation:none !important; }
}
`;

/* ---------------- Loomi the puppy (SVG) ---------------- */
/* Brand-sheet fidelity: outlined cartoon style, gradient shading, pink inner
   ears, tan points, expressive eyes. `happy` = waving pose with tongue. */
function Puppy({ size = 190, happy = false }) {
  const uid = React.useId().replace(/:/g, "");
  const navyG = `navyG-${uid}`, tanG = `tanG-${uid}`, irisG = `irisG-${uid}`;
  const O = "#16222D"; // outline ink
  return (
    <svg
      viewBox="0 0 480 520"
      width={size}
      height={(size * 520) / 480}
      className="puppy"
      role="img"
      aria-label="Loomi, a friendly Doberman puppy"
    >
      <defs>
        <linearGradient id={navyG} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#2A4257" /><stop offset="1" stopColor="#1B2B39" />
        </linearGradient>
        <linearGradient id={tanG} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#F5A257" /><stop offset="1" stopColor="#DD7E2F" />
        </linearGradient>
        <radialGradient id={irisG} cx=".38" cy=".32" r=".9">
          <stop offset="0" stopColor="#8A5526" /><stop offset="1" stopColor="#3C2716" />
        </radialGradient>
      </defs>
      <g stroke={O} strokeWidth="7" strokeLinejoin="round" strokeLinecap="round">
        {/* ground shadow */}
        <ellipse cx="240" cy="492" rx="150" ry="22" fill="var(--rose-deep)" stroke="none" opacity=".55" />

        {/* tail */}
        <path d="M356 420 Q400 410 404 372 Q407 348 388 342 Q394 366 372 384 Q356 396 344 400 Z" fill={`url(#${navyG})`} />

        {/* haunches + back paws */}
        <path d="M158 340 Q118 368 116 424 Q116 470 162 480 L196 484 Q160 428 168 364 Z" fill={`url(#${navyG})`} />
        <path d="M322 340 Q362 368 364 424 Q364 470 318 480 L284 484 Q320 428 312 364 Z" fill={`url(#${navyG})`} />
        <path d="M128 458 Q118 486 150 488 Q176 489 180 470 Q182 456 166 452 Q142 448 128 458 Z" fill={`url(#${tanG})`} strokeWidth="6" />
        <path d="M352 458 Q362 486 330 488 Q304 489 300 470 Q298 456 314 452 Q338 448 352 458 Z" fill={`url(#${tanG})`} strokeWidth="6" />

        {/* body + chest bib */}
        <path d="M240 268 C176 268 142 316 138 380 C134 446 178 486 240 486 C302 486 346 446 342 380 C338 316 304 268 240 268 Z" fill={`url(#${navyG})`} />
        <path d="M240 292 C208 292 190 326 190 372 C190 424 212 452 240 452 C268 452 290 424 290 372 C290 326 272 292 240 292 Z" fill={`url(#${tanG})`} strokeWidth="6" />

        {/* left front leg + paw */}
        <path d="M196 368 L196 452 Q196 470 214 470 L222 470 Q238 470 238 452 L238 368 Z" fill={`url(#${navyG})`} strokeWidth="6" />
        <path d="M182 452 Q178 484 214 486 Q244 487 244 464 Q244 448 224 446 Q196 444 182 452 Z" fill={`url(#${tanG})`} strokeWidth="6" />
        <path d="M206 466 L206 484 M222 468 L222 486" fill="none" strokeWidth="4" opacity=".8" />

        {happy ? (
          <>
            {/* right front leg raised, waving */}
            <path d="M282 380 Q318 356 336 316 L352 330 Q336 376 300 402 Q284 412 276 398 Q272 388 282 380 Z" fill={`url(#${navyG})`} strokeWidth="6" />
            <ellipse cx="352" cy="306" rx="30" ry="27" fill={`url(#${tanG})`} strokeWidth="6" />
            <ellipse cx="352" cy="313" rx="12" ry="9" fill="var(--tan-dark)" stroke="none" />
            <circle cx="338" cy="296" r="5.5" fill="var(--tan-dark)" stroke="none" />
            <circle cx="352" cy="292" r="5.5" fill="var(--tan-dark)" stroke="none" />
            <circle cx="366" cy="296" r="5.5" fill="var(--tan-dark)" stroke="none" />
            {/* motion ticks */}
            <path d="M392 258 L404 240 M406 282 L424 272 M370 244 L376 224" fill="none" stroke="var(--teal)" strokeWidth="8" />
          </>
        ) : (
          <>
            {/* right front leg down */}
            <path d="M284 368 L284 452 Q284 470 266 470 L258 470 Q242 470 242 452 L242 368 Z" fill={`url(#${navyG})`} strokeWidth="6" />
            <path d="M298 452 Q302 484 266 486 Q236 487 236 464 Q236 448 256 446 Q284 444 298 452 Z" fill={`url(#${tanG})`} strokeWidth="6" />
            <path d="M274 466 L274 484 M258 468 L258 486" fill="none" strokeWidth="4" opacity=".8" />
          </>
        )}

        {/* ears (pink interiors) */}
        <path d="M158 132 L108 22 Q102 8 118 14 L216 96 Z" fill={`url(#${navyG})`} />
        <path d="M162 116 L126 40 Q122 30 133 36 L198 96 Z" fill="#F2A9B4" strokeWidth="5" />
        <path d="M322 132 L372 22 Q378 8 362 14 L264 96 Z" fill={`url(#${navyG})`} />
        <path d="M318 116 L354 40 Q358 30 347 36 L282 96 Z" fill="#F2A9B4" strokeWidth="5" />

        {/* head + sheen + brows + muzzle */}
        <ellipse cx="240" cy="190" rx="112" ry="100" fill={`url(#${navyG})`} />
        <path d="M164 130 Q198 100 244 98 Q206 116 190 150 Q176 138 164 130 Z" fill="#33495D" stroke="none" opacity=".55" />
        <ellipse cx="196" cy="149" rx="19" ry="12" fill={`url(#${tanG})`} strokeWidth="5" />
        <ellipse cx="284" cy="149" rx="19" ry="12" fill={`url(#${tanG})`} strokeWidth="5" />
        <path d="M240 168 C196 168 172 194 172 226 C172 258 200 278 240 278 C280 278 308 258 308 226 C308 194 284 168 240 168 Z" fill={`url(#${tanG})`} strokeWidth="6" />

        {/* eyes */}
        <ellipse cx="198" cy="185" rx="25" ry="29" fill="#FFF9F2" strokeWidth="5" />
        <ellipse cx="282" cy="185" rx="25" ry="29" fill="#FFF9F2" strokeWidth="5" />
        <circle cx="202" cy="189" r="17" fill={`url(#${irisG})`} stroke="none" />
        <circle cx="278" cy="189" r="17" fill={`url(#${irisG})`} stroke="none" />
        <circle cx="202" cy="191" r="8" fill="#1A0F07" stroke="none" />
        <circle cx="278" cy="191" r="8" fill="#1A0F07" stroke="none" />
        <circle cx="196" cy="181" r="6" fill="#fff" stroke="none" />
        <circle cx="272" cy="181" r="6" fill="#fff" stroke="none" />
        <circle cx="208" cy="197" r="2.8" fill="#fff" stroke="none" opacity=".8" />
        <circle cx="284" cy="197" r="2.8" fill="#fff" stroke="none" opacity=".8" />
        {!happy && (
          <>
            <ellipse className="lid" cx="198" cy="185" rx="26" ry="30" fill="var(--navy)" strokeWidth="5" />
            <ellipse className="lid" cx="282" cy="185" rx="26" ry="30" fill="var(--navy)" strokeWidth="5" />
          </>
        )}

        {/* nose */}
        <path d="M240 205 Q262 205 262 221 Q262 237 240 237 Q218 237 218 221 Q218 205 240 205 Z" fill={O} strokeWidth="5" />
        <ellipse cx="232" cy="215" rx="6" ry="4" fill="#5C6B77" stroke="none" opacity=".8" />

        {/* mouth */}
        {happy ? (
          <>
            <path d="M204 240 Q240 282 276 240 Q262 268 240 268 Q218 268 204 240 Z" fill="#7A2020" strokeWidth="6" />
            <path d="M226 254 Q240 250 254 254 Q254 274 240 276 Q226 274 226 254 Z" fill="#F27D8A" strokeWidth="5" />
          </>
        ) : (
          <path d="M240 239 Q240 253 222 257 M240 239 Q240 253 258 257" fill="none" strokeWidth="6" />
        )}

        {/* collar + tag */}
        <path d="M168 296 Q240 336 312 296 L312 322 Q240 362 168 322 Z" fill="var(--red)" strokeWidth="6" />
        <line x1="240" y1="338" x2="240" y2="352" strokeWidth="6" stroke="#B98F1E" />
        <circle cx="240" cy="368" r="19" fill="var(--gold)" strokeWidth="6" />
        <circle cx="240" cy="368" r="6.5" fill="var(--gold-deep)" stroke="none" />
      </g>
    </svg>
  );
}

/* ---------------- breathing exercise ---------------- */
const PHASES = [
  { key: "in", label: "Breathe in", secs: 4, scale: 1 },
  { key: "hold1", label: "Hold", secs: 4, scale: 1 },
  { key: "out", label: "Breathe out", secs: 6, scale: 0.5 },
  { key: "hold2", label: "Rest", secs: 2, scale: 0.5 },
];

function Breathing({ onDone, onBack }) {
  const [pi, setPi] = useState(0);
  const [secs, setSecs] = useState(PHASES[0].secs);
  const [cycles, setCycles] = useState(0);
  const phase = PHASES[pi];

  useEffect(() => {
    const t = setInterval(() => {
      setSecs((s) => {
        if (s > 1) return s - 1;
        setPi((p) => {
          const next = (p + 1) % PHASES.length;
          if (next === 0) setCycles((c) => c + 1);
          return next;
        });
        return PHASES[(pi + 1) % PHASES.length].secs;
      });
    }, 1000);
    return () => clearInterval(t);
  }, [pi]);

  const animate = phase.key === "in" || phase.key === "out";

  return (
    <div className="flow">
      <div className="orb-stage" aria-live="polite">
        <div className="orb-ring" style={{
          transform: `scale(${phase.scale})`,
          transition: `transform ${animate ? phase.secs : 0.4}s ease-in-out`,
        }} />
        <div className="orb" style={{
          transform: `scale(${phase.scale})`,
          transition: `transform ${animate ? phase.secs : 0.4}s ease-in-out`,
        }}>
          <div className="orb-label">{phase.label}<span className="cnt">{secs}</span></div>
        </div>
      </div>
      <div className="breath-meta">{cycles} {cycles === 1 ? "breath" : "breaths"} together · Loomi's breathing with you</div>
      <div style={{ marginTop: 18 }}>
        <Puppy size={120} />
      </div>
      <button className="choice alt" onClick={onDone} style={{ marginTop: 18 }}>I'm feeling steadier →</button>
      <button className="ghost" onClick={onBack}>← Back</button>
    </div>
  );
}

/* ---------------- grounding 5-4-3-2-1 ---------------- */
const SENSES = [
  { n: 5, sense: "things you can see", tip: "Look around and name them — a mug, the light, your hands." },
  { n: 4, sense: "things you can feel", tip: "The floor under you, your shirt, the air, something nearby to touch." },
  { n: 3, sense: "things you can hear", tip: "Traffic, a fan, your own breath. Let the sounds in." },
  { n: 2, sense: "things you can smell", tip: "Coffee, soap, fresh air — or just notice the absence." },
  { n: 1, sense: "thing you can taste", tip: "A sip of water, gum, or the taste already in your mouth." },
];

function Grounding({ onDone, onBack }) {
  const [i, setI] = useState(0);
  const s = SENSES[i];
  const last = i === SENSES.length - 1;
  return (
    <div className="flow">
      <div className="eyebrow" style={{ marginTop: 6 }}>Grounding · 5-4-3-2-1</div>
      <div style={{ fontFamily: "Nunito Sans", fontWeight: 800, fontSize: 64, color: "var(--red)", lineHeight: 1 }}>{s.n}</div>
      <div className="line" style={{ marginTop: 0 }}>{s.sense}</div>
      <p className="hint">{s.tip}</p>
      <div className="dots">{SENSES.map((_, k) => <i key={k} className={k <= i ? "on" : ""} />)}</div>
      <button className="choice alt" onClick={() => (last ? onDone() : setI(i + 1))} style={{ marginTop: 16 }}>
        {last ? "Done — that's grounding" : "Next"}
      </button>
      <button className="ghost" onClick={onBack}>← Back</button>
    </div>
  );
}

/* ---------------- reframe the stressor ---------------- */
function Reframe({ onDone }) {
  const [step, setStep] = useState(0);
  const [what, setWhat] = useState("");
  const [control, setControl] = useState(null);
  const [step3, setStep3] = useState("");

  if (step === 0) {
    return (
      <div className="flow">
        <div className="line">What's weighing on you right now?</div>
        <p className="hint">Just naming it takes some of its power away. No one else sees this.</p>
        <textarea className="field" value={what} onChange={(e) => setWhat(e.target.value)} placeholder="Type whatever's on your mind…" />
        <button className="choice alt" onClick={() => setStep(1)} style={{ marginTop: 12 }}>Next →</button>
      </div>
    );
  }
  if (step === 1) {
    return (
      <div className="flow">
        <div className="line">Is this something you can act on right now?</div>
        <p className="hint">Stress eases when we sort what's ours to carry from what isn't — yet.</p>
        <div className="row2">
          <button className="choice" onClick={() => { setControl("yes"); setStep(2); }}>Yes, partly</button>
          <button className="choice" onClick={() => { setControl("no"); setStep(2); }}>Not right now</button>
        </div>
      </div>
    );
  }
  return (
    <div className="flow">
      {control === "yes" ? (
        <>
          <div className="line">What's the smallest next step?</div>
          <p className="hint">Not the whole thing — just the very next move. Small counts.</p>
        </>
      ) : (
        <>
          <div className="line">What could you set down for now?</div>
          <p className="hint">If you can't act yet, you're allowed to put it down until you can. That's not giving up.</p>
        </>
      )}
      <textarea className="field" value={step3} onChange={(e) => setStep3(e.target.value)} placeholder="One small thing…" />
      <button className="choice alt" onClick={onDone} style={{ marginTop: 12 }}>I'm ready →</button>
    </div>
  );
}

/* ---------------- relief flow shell ---------------- */
function Relief({ goHome }) {
  const [step, setStep] = useState("intro");

  if (step === "intro") {
    return (
      <div className="flow">
        <div className="float" style={{ display: "inline-block" }}><Puppy size={170} /></div>
        <div className="line">Hey, I'm right here.</div>
        <p className="hint">You're safe. Whatever's stressing you, we don't have to fix it all at once. Let's just steady your body first.</p>
        <button className="choice" onClick={() => setStep("breathe")}>Walk me through it</button>
        <button className="choice alt" onClick={() => setStep("breathe")}>I just need to breathe</button>
        <button className="ghost" onClick={goHome}>← Not now</button>
      </div>
    );
  }
  if (step === "breathe") return <Breathing onDone={() => setStep("ground")} onBack={() => setStep("intro")} />;
  if (step === "ground") return <Grounding onDone={() => setStep("reframe")} onBack={() => setStep("breathe")} />;
  if (step === "reframe") return <Reframe onDone={() => setStep("done")} />;

  return (
    <div className="flow">
      <div className="bounce" style={{ display: "inline-block" }}><Puppy size={170} happy /></div>
      <div className="line">You did that. I'm proud of you.</div>
      <p className="hint">You showed up for yourself in a hard moment — that's the whole skill. How are you feeling?</p>
      <button className="choice" onClick={goHome}>Calmer — thanks, Loomi</button>
      <button className="choice" onClick={goHome}>A bit better</button>
      <button className="choice alt" onClick={() => setStep("breathe")}>Still rough — let's breathe again</button>
    </div>
  );
}

/* ---------------- learning content ---------------- */
const UNDERSTAND = [
  ["Stress is an alarm, not a flaw", "It's your body's built-in protection system. A threat (real or imagined) triggers adrenaline and cortisol to prep you to act. It's ancient, automatic, and not a sign anything's wrong with you."],
  ["Acute vs. chronic", "Short bursts of stress can sharpen focus and even help you perform. The problem is when the alarm never switches off — that constant 'on' is what wears the body and mind down."],
  ["Where you feel it", "Tight chest, shallow breath, clenched jaw, racing thoughts, a knotted stomach, a short fuse. These are physical, not 'just in your head' — which is why physical tools work."],
  ["What sets it off", "Uncertainty, feeling overloaded, having too little control, and never getting recovery time. Naming your trigger is the first step to loosening its grip."],
];

const TECHNIQUES = [
  ["Breathe out longer", "A slow exhale (longer than the inhale) tells your nervous system the danger has passed. Try Loomi's button — in for 4, out for 6."],
  ["Ground with 5-4-3-2-1", "Name 5 things you see, 4 you feel, 3 you hear, 2 you smell, 1 you taste. It pulls a spinning mind back to right now."],
  ["Cool down, literally", "Cold water on your face or wrists triggers a reflex that slows your heart rate. A surprisingly fast reset."],
  ["Move it out", "Stress is adrenaline with nowhere to go. A brisk walk, shaking out your hands, or stretching burns it off."],
  ["Drop your shoulders", "Do a quick body scan — unclench your jaw, lower your shoulders, soften your hands. We hold stress as tension we don't notice."],
  ["Brain-dump the list", "Get every looming task out of your head and onto paper. You can't hold it all at once, and you were never meant to."],
];

const RESILIENCE = [
  ["Protect your sleep", "Sleep is the foundation everything else sits on. Even one bad night raises baseline stress; a steady schedule lowers it."],
  ["Move most days", "Regular movement is one of the most reliable stress reducers there is — it doesn't have to be intense to count."],
  ["Watch caffeine & alcohol", "Both can amplify anxiety and wreck sleep. You don't have to quit — just notice how they land for you."],
  ["Stay connected", "Talking to someone you trust genuinely lowers stress hormones. Isolation makes everything feel heavier than it is."],
  ["Practice the small no", "Overload often comes from over-committing. Boundaries aren't selfish — they're how you stay able to show up at all."],
  ["Build in recovery", "Tiny breaks through the day beat one big collapse later. Step outside, breathe, look away from the screen."],
  ["Be kind to yourself", "Talk to yourself like you'd talk to a friend having a hard day. Self-criticism is just more stress on the pile."],
  ["Get backup if it's constant", "If stress is steady and affecting your life, a doctor or therapist can help. CBT is especially well-proven for this — see Support."],
];

function Lessons({ title, eyebrow, items, goHome }) {
  return (
    <div>
      <div className="page-head">
        <button className="back" onClick={goHome} aria-label="Back">←</button>
        <h2 className="loomi-h">{title}</h2>
      </div>
      <div className="eyebrow" style={{ marginBottom: 14 }}>{eyebrow}</div>
      {items.map((it, k) => (
        <div className="card lesson" key={k}>
          <h3><span className="num">{String(k + 1).padStart(2, "0")}</span> &nbsp;{it[0]}</h3>
          <p>{it[1]}</p>
        </div>
      ))}
      <div style={{ textAlign: "center", marginTop: 16 }}>
        <Puppy size={110} />
      </div>
    </div>
  );
}

/* ---------------- support ---------------- */
function Support({ goHome }) {
  return (
    <div>
      <div className="page-head">
        <button className="back" onClick={goHome} aria-label="Back">←</button>
        <h2 className="loomi-h">Support</h2>
      </div>
      <div className="card" style={{ marginBottom: 14 }}>
        <p className="note" style={{ fontSize: 14 }}>
          Loomi is a self-help companion for everyday stress — not a doctor or therapist, and not a
          substitute for professional care. If stress is steady, heavy, or getting in the way of
          your life, please reach out to a real person who can help.
        </p>
      </div>
      <div className="eyebrow" style={{ marginBottom: 10 }}>If you need someone now (US)</div>
      <div className="res">
        <div className="rt">988 Suicide &amp; Crisis Lifeline</div>
        <div className="rd">Free, 24/7, for any kind of emotional crisis or distress. Call or text <a href="tel:988">988</a>.</div>
      </div>
      <div className="res">
        <div className="rt">Crisis Text Line</div>
        <div className="rd">Text <strong>HOME</strong> to <a href="sms:741741">741741</a> to message a trained counselor, any time.</div>
      </div>
      <div className="res">
        <div className="rt">In immediate danger</div>
        <div className="rd">If you or someone else is at risk right now, call your local emergency number (911 in the US).</div>
      </div>
      <div className="res">
        <div className="rt">Talk to a professional</div>
        <div className="rd">A doctor or therapist can help you build a longer-term plan. Cognitive behavioral therapy (CBT) is especially effective for stress and anxiety.</div>
      </div>
      <p className="note" style={{ textAlign: "center", marginTop: 8 }}>Outside the US? Search "crisis line" plus your country — most regions have a free helpline.</p>
      <div style={{ textAlign: "center", marginTop: 14 }}><Puppy size={110} /></div>
    </div>
  );
}

/* ---------------- home ---------------- */
function Home({ go }) {
  return (
    <div>
      <div className="hero">
        <div className="speech">Rough day? Tap below and we'll get through it together. 🐾</div>
        <div className="float" style={{ display: "inline-block" }}><Puppy size={196} /></div>
        <h1 className="loomi-h">Hi, I'm Loomi.</h1>
        <p className="sub">Your pocket guardian for stressful moments — here to help you breathe, ground, and feel steady again.</p>
        <button className="big-btn" onClick={() => go("relief")}>
          I'm feeling stressed
          <small>press anytime — I've got you</small>
        </button>
      </div>

      <div className="nav-grid">
        <button className="nav-card" onClick={() => go("understand")}>
          <div className="ico">🧠</div>
          <div className="t">Understand stress</div>
          <div className="d">What it is and why it happens</div>
        </button>
        <button className="nav-card" onClick={() => go("techniques")}>
          <div className="ico">🌿</div>
          <div className="t">In-the-moment</div>
          <div className="d">Quick ways to feel calmer fast</div>
        </button>
        <button className="nav-card" onClick={() => go("resilience")}>
          <div className="ico">🌱</div>
          <div className="t">Build resilience</div>
          <div className="d">Habits that lower stress over time</div>
        </button>
        <button className="nav-card" onClick={() => go("support")}>
          <div className="ico">💛</div>
          <div className="t">Support</div>
          <div className="d">Resources for when it's a lot</div>
        </button>
      </div>
    </div>
  );
}

/* ---------------- app shell ---------------- */
export default function App() {
  const [screen, setScreen] = useState("home");
  const topRef = useRef(null);
  const go = (s) => setScreen(s);
  useEffect(() => { topRef.current && topRef.current.scrollIntoView({ block: "start" }); }, [screen]);

  return (
    <div className="loomi-app">
      <style>{STYLES}</style>
      <div className="loomi-wrap" ref={topRef}>
        <div className="topbar">
          <button className="brandmark" onClick={() => go("home")} style={{ background: "transparent" }} aria-label="Loomi home">
            <span className="dot"><span /></span>
            <span className="brandname">Loomi</span>
          </button>
          {screen !== "support" && (
            <button className="help-pill" onClick={() => go("support")}>Need support?</button>
          )}
        </div>

        {screen === "home" && <Home go={go} />}
        {screen === "relief" && <Relief goHome={() => go("home")} />}
        {screen === "understand" && <Lessons title="Understand stress" eyebrow="The basics" items={UNDERSTAND} goHome={() => go("home")} />}
        {screen === "techniques" && <Lessons title="In-the-moment" eyebrow="Fast relief" items={TECHNIQUES} goHome={() => go("home")} />}
        {screen === "resilience" && <Lessons title="Build resilience" eyebrow="Over time" items={RESILIENCE} goHome={() => go("home")} />}
        {screen === "support" && <Support goHome={() => go("home")} />}
      </div>
    </div>
  );
}
