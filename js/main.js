(() => {
  // ── Theme ──
  const root = document.documentElement;
  const KEY = 'theme';
  const stored = localStorage.getItem(KEY);
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  root.dataset.theme = stored || (prefersDark ? 'dark' : 'light');

  const setTheme = t => {
    root.dataset.theme = t;
    localStorage.setItem(KEY, t);
  };
  const toggle = () => setTheme(root.dataset.theme === 'dark' ? 'light' : 'dark');
  document.getElementById('themeToggle')?.addEventListener('click', toggle);
  document.getElementById('drawerThemeToggle')?.addEventListener('click', toggle);

  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
    if (!localStorage.getItem(KEY)) setTheme(e.matches ? 'dark' : 'light');
  });

  // ── Mobile drawer ──
  const hamb = document.getElementById('hamb');
  const drawer = document.getElementById('drawer');
  const closeMenu = () => { document.body.classList.remove('menu-open'); hamb.setAttribute('aria-expanded', 'false'); };
  const openMenu  = () => { document.body.classList.add('menu-open');    hamb.setAttribute('aria-expanded', 'true'); };
  hamb?.addEventListener('click', () => document.body.classList.contains('menu-open') ? closeMenu() : openMenu());
  drawer?.querySelectorAll('a').forEach(a => a.addEventListener('click', closeMenu));
  document.addEventListener('keydown', e => { if (e.key === 'Escape') closeMenu(); });

  // ── Reveal on scroll ──
  const revealObs = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (e.isIntersecting) { e.target.classList.add('visible'); revealObs.unobserve(e.target); }
    });
  }, { threshold: 0.12 });
  document.querySelectorAll('.reveal').forEach(el => revealObs.observe(el));

  // ── Active section in nav ──
  const navLinks = document.querySelectorAll('#nav-links a[href^="#"]');
  const sectionIds = Array.from(navLinks).map(a => a.getAttribute('href').slice(1));
  const sections = sectionIds.map(id => document.getElementById(id)).filter(Boolean);
  const setActive = id => navLinks.forEach(a => a.classList.toggle('active', a.getAttribute('href') === '#' + id));
  const navObs = new IntersectionObserver(entries => {
    entries.forEach(e => { if (e.isIntersecting) setActive(e.target.id); });
  }, { rootMargin: '-40% 0px -55% 0px', threshold: 0 });
  sections.forEach(s => navObs.observe(s));

  // ── Skill block radial-glow follow cursor ──
  document.querySelectorAll('.skill-block').forEach(block => {
    block.addEventListener('pointermove', e => {
      const r = block.getBoundingClientRect();
      block.style.setProperty('--mx', ((e.clientX - r.left) / r.width * 100) + '%');
      block.style.setProperty('--my', ((e.clientY - r.top) / r.height * 100) + '%');
    });
  });

  // ── Copy email ──
  const copyBtn = document.getElementById('copyEmail');
  const email = 'arnau.baeza@gmail.com';
  copyBtn?.addEventListener('click', async () => {
    try { await navigator.clipboard.writeText(email); }
    catch {
      const ta = document.createElement('textarea');
      ta.value = email; ta.style.position = 'fixed'; ta.style.opacity = '0';
      document.body.appendChild(ta); ta.select();
      try { document.execCommand('copy'); } catch {}
      document.body.removeChild(ta);
    }
    copyBtn.classList.add('copied');
    setTimeout(() => copyBtn.classList.remove('copied'), 1600);
  });

  // ── Live status pill from /status.json ──
  const statusLink = document.getElementById('footerStatus');
  if (statusLink) {
    fetch('/status.json', { cache: 'no-cache' }).then(r => r.ok ? r.json() : null).then(d => {
      if (!d) return;
      const days = Math.floor(d.uptime_seconds / 86400);
      const hours = Math.floor((d.uptime_seconds % 86400) / 3600);
      const up = days >= 1 ? `${days}d ${hours}h` : `${hours}h`;
      const bans = (d.banned_ips && typeof d.banned_ips === 'object') ? d.banned_ips.total : d.banned_ips;
      statusLink.textContent = `up ${up} · cert ${d.cert_days_remaining}d · load ${d.load['1m']}`;
      statusLink.title = `RAM ${d.memory_mib.used}/${d.memory_mib.total} MiB · ${bans} IP banned · disk ${d.disk_root.used_pct}%`;
    }).catch(() => {});
  }

  // ── Web Vitals (sendBeacon to /vitals) ──
  if ('PerformanceObserver' in window) {
    const sendVital = (name, value) => {
      try {
        const body = JSON.stringify({
          name, value: Math.round(value * 1000) / 1000,
          path: location.pathname, lang: document.documentElement.lang,
          ua: navigator.userAgent.slice(0, 200), ts: Date.now()
        });
        if (navigator.sendBeacon) navigator.sendBeacon('/vitals', body);
      } catch {}
    };
    // LCP
    try {
      const po = new PerformanceObserver(list => {
        const e = list.getEntries().pop();
        if (e) sendVital('LCP', e.startTime);
      });
      po.observe({ type: 'largest-contentful-paint', buffered: true });
    } catch {}
    // CLS
    let cls = 0;
    try {
      const po2 = new PerformanceObserver(list => {
        list.getEntries().forEach(e => { if (!e.hadRecentInput) cls += e.value; });
      });
      po2.observe({ type: 'layout-shift', buffered: true });
    } catch {}
    // INP-like (event timing)
    let inpMax = 0;
    try {
      const po3 = new PerformanceObserver(list => {
        list.getEntries().forEach(e => { if (e.duration > inpMax) inpMax = e.duration; });
      });
      po3.observe({ type: 'event', durationThreshold: 16, buffered: true });
    } catch {}
    // Flush on hide
    addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'hidden') {
        if (cls) sendVital('CLS', cls);
        if (inpMax) sendVital('INP', inpMax);
        try {
          const nav = performance.getEntriesByType('navigation')[0];
          if (nav) {
            sendVital('TTFB', nav.responseStart);
            sendVital('LOAD', nav.loadEventEnd);
          }
        } catch {}
      }
    }, { once: true });
  }
})();

