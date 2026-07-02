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
function Puppy({ size = 190, happy = false }) {
  return (
    <svg
      viewBox="0 0 240 260"
      width={size}
      height={(size * 260) / 240}
      className="puppy"
      role="img"
      aria-label="Loomi, a friendly Doberman puppy"
    >
      <ellipse cx="120" cy="246" rx="76" ry="12" fill="var(--rose-deep)" opacity="0.5" />

      {/* ears */}
      <path d="M88 66 L60 10 Q57 4 64 7 L110 54 Z" fill="var(--navy)" />
      <path d="M85 60 L68 24 Q66 19 72 22 L102 54 Z" fill="var(--tan)" />
      <path d="M152 66 L180 10 Q183 4 176 7 L130 54 Z" fill="var(--navy)" />
      <path d="M155 60 L172 24 Q174 19 168 22 L138 54 Z" fill="var(--tan)" />

      {/* body */}
      <path d="M120 150 C92 150 78 168 72 196 C68 222 88 238 120 238 C152 238 172 222 168 196 C162 168 148 150 120 150 Z" fill="var(--navy)" />
      {/* chest bib */}
      <path d="M120 160 C107 160 99 173 99 191 C99 210 109 222 120 222 C131 222 141 210 141 191 C141 173 133 160 120 160 Z" fill="var(--tan)" />
      {/* legs + paws */}
      <rect x="93" y="198" width="22" height="42" rx="11" fill="var(--navy)" />
      <rect x="125" y="198" width="22" height="42" rx="11" fill="var(--navy)" />
      <rect x="90" y="221" width="27" height="20" rx="10" fill="var(--tan)" />
      <rect x="123" y="221" width="27" height="20" rx="10" fill="var(--tan)" />
      <path d="M103 226 L103 239 M97 227 L97 238 M109 227 L109 238" stroke="var(--tan-dark)" strokeWidth="1.6" opacity=".5" />
      <path d="M137 226 L137 239 M131 227 L131 238 M143 227 L143 238" stroke="var(--tan-dark)" strokeWidth="1.6" opacity=".5" />

      {/* head */}
      <ellipse cx="120" cy="92" rx="56" ry="50" fill="var(--navy)" />
      {/* eyebrows */}
      <ellipse cx="98" cy="73" rx="9" ry="5.5" fill="var(--tan)" />
      <ellipse cx="142" cy="73" rx="9" ry="5.5" fill="var(--tan)" />
      {/* muzzle */}
      <ellipse cx="120" cy="112" rx="35" ry="29" fill="var(--tan)" />

      {/* eyes */}
      <g>
        <ellipse cx="99" cy="91" rx="12.5" ry="14.5" fill="var(--cream)" />
        <ellipse cx="141" cy="91" rx="12.5" ry="14.5" fill="var(--cream)" />
        {happy ? (
          <>
            <path d="M90 92 Q99 84 108 92" stroke="var(--navy-deep)" strokeWidth="4" fill="none" strokeLinecap="round" />
            <path d="M132 92 Q141 84 150 92" stroke="var(--navy-deep)" strokeWidth="4" fill="none" strokeLinecap="round" />
          </>
        ) : (
          <>
            <ellipse cx="101" cy="93" rx="8.5" ry="10" fill="#3C2716" />
            <ellipse cx="143" cy="93" rx="8.5" ry="10" fill="#3C2716" />
            <circle cx="98" cy="89" r="3" fill="#fff" />
            <circle cx="140" cy="89" r="3" fill="#fff" />
            {/* blink lids */}
            <ellipse className="lid" cx="99" cy="91" rx="13" ry="15" fill="var(--navy)" />
            <ellipse className="lid" cx="141" cy="91" rx="13" ry="15" fill="var(--navy)" />
          </>
        )}
      </g>

      {/* nose + mouth */}
      <ellipse cx="120" cy="103" rx="11" ry="8.5" fill="var(--navy-deep)" />
      <ellipse cx="116" cy="100" rx="3" ry="2" fill="#7C8893" opacity=".7" />
      <path d="M120 111 Q120 122 110 126 M120 111 Q120 122 130 126" stroke="var(--navy-deep)" strokeWidth="3" fill="none" strokeLinecap="round" />

      {/* collar + tag */}
      <path d="M84 148 Q120 168 156 148 L156 161 Q120 181 84 161 Z" fill="var(--red)" />
      <path d="M84 148 Q120 168 156 148" stroke="var(--red-deep)" strokeWidth="2" fill="none" opacity=".5" />
      <line x1="120" y1="170" x2="120" y2="178" stroke="var(--gold-deep)" strokeWidth="3" />
      <circle cx="120" cy="186" r="10" fill="var(--gold)" stroke="var(--gold-deep)" strokeWidth="2" />
      <circle cx="120" cy="186" r="3.5" fill="var(--gold-deep)" opacity=".55" />
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
