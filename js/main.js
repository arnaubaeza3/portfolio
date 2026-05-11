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
})();

