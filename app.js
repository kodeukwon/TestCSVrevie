/* 나만의 레시피 앱
 * - localStorage 기반 개인용 레시피 관리
 * - CRUD, 검색, 별점, 카테고리, 인분 양 자동 계산
 */
(() => {
  'use strict';

  const STORAGE_KEY = 'my-recipes-v1';

  // ---------- Sample seed ----------
  const SAMPLE_RECIPES = [
    {
      id: 'seed-kkaennip-dakdoritang',
      name: '깻잎 닭도리탕',
      rating: 3,
      category: '한식',
      source: '인스타 saengcho_halmae',
      servings: 3,
      ingredients: [
        { name: '닭', amount: 1, unit: '마리' },
        { name: '물', amount: null, unit: '잠길 만큼' },
        { name: '양파', amount: 0.5, unit: '개' },
        { name: '감자', amount: 4, unit: '개', note: '작은거' },
        { name: '떡', amount: null, unit: '한 줌', note: '선택' },
        { name: '대파', amount: null, unit: '한 줌' },
        { name: '청양고추', amount: 2, unit: '개' },
        { name: '깻잎', amount: 8, unit: '장' },
      ],
      sauce: [
        { name: '고추장', amount: 1, unit: 'T', note: '크게' },
        { name: '후추', amount: null, unit: '적당히' },
        { name: '고춧가루', amount: 3, unit: 'T' },
        { name: '굴소스', amount: 1.5, unit: 'T' },
        { name: '진간장', amount: 3, unit: 'T' },
        { name: '맛술 or 미림', amount: 3, unit: 'T' },
        { name: '치킨스톡', amount: 1, unit: 'T' },
        { name: '설탕', amount: 2, unit: 'T' },
        { name: '다진마늘', amount: 1, unit: 'T' },
        { name: '미원', amount: null, unit: '약간', note: '선택' },
      ],
      steps: [
        '끓는 물에 닭을 5분간 데친 후 찬물에 깨끗하게 씻는다.',
        '감자, 양념장을 넣는다.',
        '감자가 어느정도 익으면 닭이 익었는지 확인하고 양파와 대파를 넣고 숨이 죽을 때까지 끓인다.',
        '마지막에 깻잎을 넣고 조금만 더 끓여주면 완성.',
      ],
      notes: '',
      createdAt: Date.now(),
      updatedAt: Date.now(),
    },
  ];

  // ---------- Storage ----------
  function loadRecipes() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw === null) {
        saveRecipes(SAMPLE_RECIPES);
        return [...SAMPLE_RECIPES];
      }
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [...SAMPLE_RECIPES];
    }
  }

  function saveRecipes(recipes) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(recipes));
  }

  // ---------- State ----------
  const state = {
    recipes: loadRecipes(),
    view: 'list',           // 'list' | 'detail' | 'form'
    selectedId: null,
    editingId: null,
    search: '',
    categoryFilter: '',
    ratingFilter: 0,
    sort: 'updated',
    detailServings: 1,
  };

  // ---------- Utilities ----------
  const uid = () => 'r-' + Math.random().toString(36).slice(2, 10) + Date.now().toString(36);

  // Parse a possibly fractional amount string into a number, or return null for descriptive amounts.
  function parseAmount(input) {
    if (input === null || input === undefined) return null;
    const s = String(input).trim();
    if (!s) return null;
    // Mixed fraction "1 1/2"
    const mixed = s.match(/^(\d+)\s+(\d+)\/(\d+)$/);
    if (mixed) {
      const [, w, n, d] = mixed;
      const denom = parseInt(d, 10);
      if (denom === 0) return null;
      return parseInt(w, 10) + parseInt(n, 10) / denom;
    }
    // Simple fraction "1/2"
    const frac = s.match(/^(\d+)\/(\d+)$/);
    if (frac) {
      const denom = parseInt(frac[2], 10);
      if (denom === 0) return null;
      return parseInt(frac[1], 10) / denom;
    }
    // Decimal
    if (/^\d+(\.\d+)?$/.test(s)) return parseFloat(s);
    return null;
  }

  // Convert a number back to a friendly fraction-aware string.
  function formatAmount(value) {
    if (value === null || value === undefined || Number.isNaN(value)) return '';
    if (value === 0) return '0';

    // Round to 3 decimals to avoid floating point noise
    const rounded = Math.round(value * 1000) / 1000;

    // If it's effectively integer
    if (Math.abs(rounded - Math.round(rounded)) < 0.001) {
      return String(Math.round(rounded));
    }

    const whole = Math.floor(rounded);
    const frac = rounded - whole;

    // Common fractions
    const fractions = [
      [1/4, '1/4'], [1/3, '1/3'], [1/2, '1/2'],
      [2/3, '2/3'], [3/4, '3/4'], [1/8, '1/8'], [3/8, '3/8'],
      [5/8, '5/8'], [7/8, '7/8'],
    ];
    for (const [val, label] of fractions) {
      if (Math.abs(frac - val) < 0.02) {
        return whole === 0 ? label : `${whole} ${label}`;
      }
    }

    // Fall back to decimal (1 dp normally, 2 dp if small)
    return rounded < 1
      ? rounded.toFixed(2).replace(/\.?0+$/, '')
      : rounded.toFixed(1).replace(/\.0$/, '');
  }

  function escapeHtml(s) {
    return String(s ?? '').replace(/[&<>"']/g, c => ({
      '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
    })[c]);
  }

  function starString(rating) {
    const r = Math.max(0, Math.min(5, Math.round(rating || 0)));
    return '⭐'.repeat(r) + '☆'.repeat(5 - r);
  }

  // ---------- Persistence helpers ----------
  function upsertRecipe(recipe) {
    const idx = state.recipes.findIndex(r => r.id === recipe.id);
    if (idx >= 0) state.recipes[idx] = recipe;
    else state.recipes.push(recipe);
    saveRecipes(state.recipes);
  }

  function deleteRecipe(id) {
    state.recipes = state.recipes.filter(r => r.id !== id);
    saveRecipes(state.recipes);
  }

  function getRecipe(id) {
    return state.recipes.find(r => r.id === id) || null;
  }

  // ---------- Filtering / sorting ----------
  function getFilteredRecipes() {
    let list = state.recipes.slice();

    if (state.search.trim()) {
      const q = state.search.trim().toLowerCase();
      list = list.filter(r => {
        if (r.name.toLowerCase().includes(q)) return true;
        if ((r.category || '').toLowerCase().includes(q)) return true;
        const allIngs = [...(r.ingredients || []), ...(r.sauce || [])];
        return allIngs.some(i => (i.name || '').toLowerCase().includes(q));
      });
    }

    if (state.categoryFilter) {
      list = list.filter(r => r.category === state.categoryFilter);
    }

    if (state.ratingFilter > 0) {
      list = list.filter(r => (r.rating || 0) >= state.ratingFilter);
    }

    if (state.sort === 'rating') {
      list.sort((a, b) => (b.rating || 0) - (a.rating || 0));
    } else if (state.sort === 'name') {
      list.sort((a, b) => a.name.localeCompare(b.name, 'ko'));
    } else {
      list.sort((a, b) => (b.updatedAt || 0) - (a.updatedAt || 0));
    }

    return list;
  }

  function getCategories() {
    const set = new Set();
    state.recipes.forEach(r => { if (r.category) set.add(r.category); });
    return Array.from(set).sort((a, b) => a.localeCompare(b, 'ko'));
  }

  // ---------- Rendering ----------
  const $ = (id) => document.getElementById(id);

  function setView(view) {
    state.view = view;
    $('list-view').classList.toggle('hidden', view !== 'list');
    $('detail-view').classList.toggle('hidden', view !== 'detail');
    $('form-view').classList.toggle('hidden', view !== 'form');
    $('back-btn').classList.toggle('hidden', view === 'list');
    $('add-btn').classList.toggle('hidden', view !== 'list');

    const titles = { list: '나만의 레시피', detail: '레시피', form: state.editingId ? '레시피 수정' : '새 레시피' };
    $('header-title').textContent = titles[view];

    window.scrollTo({ top: 0, behavior: 'instant' });
  }

  function renderList() {
    const list = getFilteredRecipes();
    const container = $('recipe-list');
    const empty = $('empty-state');

    if (state.recipes.length === 0) {
      container.innerHTML = '';
      empty.classList.remove('hidden');
      return;
    }

    empty.classList.add('hidden');

    if (list.length === 0) {
      container.innerHTML = '<p style="text-align:center;color:var(--text-muted);padding:24px;">조건에 맞는 레시피가 없어요.</p>';
      return;
    }

    container.innerHTML = list.map(r => {
      const ingPreview = (r.ingredients || []).slice(0, 4).map(i => i.name).join(', ');
      return `
        <div class="recipe-card" data-id="${escapeHtml(r.id)}" role="button" tabindex="0">
          <h3>${escapeHtml(r.name)}</h3>
          <div class="card-meta">
            <span class="rating">${starString(r.rating)}</span>
            ${r.category ? `<span class="tag">${escapeHtml(r.category)}</span>` : ''}
          </div>
          ${ingPreview ? `<p class="preview">${escapeHtml(ingPreview)}</p>` : ''}
        </div>
      `;
    }).join('');
  }

  function renderCategoryOptions() {
    const cats = getCategories();
    const sel = $('category-filter');
    const current = state.categoryFilter;
    sel.innerHTML = '<option value="">전체 카테고리</option>' +
      cats.map(c => `<option value="${escapeHtml(c)}"${c === current ? ' selected' : ''}>${escapeHtml(c)}</option>`).join('');

    const datalist = $('category-list');
    datalist.innerHTML = cats.map(c => `<option value="${escapeHtml(c)}">`).join('');
  }

  function renderDetail() {
    const r = getRecipe(state.selectedId);
    if (!r) { setView('list'); return; }

    state.detailServings = r.servings || 1;

    $('detail-name').textContent = r.name;
    $('detail-rating').textContent = starString(r.rating);

    const catEl = $('detail-category');
    if (r.category) { catEl.textContent = r.category; catEl.classList.remove('hidden'); }
    else { catEl.textContent = ''; catEl.classList.add('hidden'); }

    const sourceEl = $('detail-source');
    if (r.source) { sourceEl.textContent = '출처: ' + r.source; sourceEl.classList.remove('hidden'); }
    else { sourceEl.textContent = ''; sourceEl.classList.add('hidden'); }

    $('serving-base').textContent = formatAmount(r.servings || 1);
    $('serving-input').value = formatAmount(state.detailServings);

    renderIngredients(r);

    const stepsList = $('detail-steps');
    stepsList.innerHTML = (r.steps || []).map(s => `<li>${escapeHtml(s)}</li>`).join('');

    const notesWrap = $('detail-notes-wrap');
    if (r.notes && r.notes.trim()) {
      notesWrap.classList.remove('hidden');
      $('detail-notes').textContent = r.notes;
    } else {
      notesWrap.classList.add('hidden');
    }
  }

  function renderIngredients(recipe) {
    const baseServings = recipe.servings || 1;
    const ratio = (state.detailServings || baseServings) / baseServings;

    const renderRow = (i) => {
      const scaledAmount = i.amount === null || i.amount === undefined ? null : i.amount * ratio;
      const amountText = scaledAmount === null
        ? escapeHtml(i.unit || '')
        : `${escapeHtml(formatAmount(scaledAmount))} ${escapeHtml(i.unit || '')}`.trim();
      return `
        <li>
          <span class="ing-detail-name">${escapeHtml(i.name)}${i.note ? ` <span class="ing-detail-note">(${escapeHtml(i.note)})</span>` : ''}</span>
          <span class="ing-detail-amount">${amountText}</span>
        </li>
      `;
    };

    $('detail-ingredients').innerHTML = (recipe.ingredients || []).map(renderRow).join('');

    const sauce = recipe.sauce || [];
    const sauceSection = $('sauce-section');
    if (sauce.length > 0) {
      sauceSection.classList.remove('hidden');
      $('detail-sauce').innerHTML = sauce.map(renderRow).join('');
    } else {
      sauceSection.classList.add('hidden');
    }
  }

  // ---------- Form ----------
  function renderForm(recipe) {
    state.editingId = recipe ? recipe.id : null;
    $('form-id').value = recipe ? recipe.id : '';
    $('form-name').value = recipe ? recipe.name : '';
    $('form-category').value = recipe ? (recipe.category || '') : '';
    $('form-source').value = recipe ? (recipe.source || '') : '';
    $('form-servings').value = recipe ? (recipe.servings || 1) : 1;
    $('form-notes').value = recipe ? (recipe.notes || '') : '';
    setRatingInput(recipe ? (recipe.rating || 0) : 0);

    $('ingredient-rows').innerHTML = '';
    (recipe?.ingredients || [{ name: '', amount: null, unit: '', note: '' }]).forEach(addIngredientRow);

    $('sauce-rows').innerHTML = '';
    (recipe?.sauce || []).forEach(s => addIngredientRow(s, 'sauce-rows'));

    $('step-rows').innerHTML = '';
    (recipe?.steps || ['']).forEach(addStepRow);

    setView('form');
  }

  function addIngredientRow(data, targetId = 'ingredient-rows') {
    const tpl = $('ingredient-row-template').content.cloneNode(true);
    const row = tpl.querySelector('.ingredient-row');
    row.querySelector('.ing-name').value = data?.name || '';
    row.querySelector('.ing-amount').value = data && data.amount !== null && data.amount !== undefined
      ? formatAmount(data.amount)
      : '';
    row.querySelector('.ing-unit').value = data?.unit || '';
    row.querySelector('.ing-note').value = data?.note || '';
    row.querySelector('.row-remove').addEventListener('click', () => row.remove());
    $(targetId).appendChild(row);
  }

  function addStepRow(text = '') {
    const tpl = $('step-row-template').content.cloneNode(true);
    const row = tpl.querySelector('.step-row');
    row.querySelector('.step-text').value = text;
    row.querySelector('.row-remove').addEventListener('click', () => row.remove());
    $('step-rows').appendChild(row);
  }

  function setRatingInput(value) {
    const wrap = $('form-rating');
    wrap.dataset.value = String(value);
    wrap.querySelectorAll('span').forEach(s => {
      const star = parseInt(s.dataset.star, 10);
      const filled = star <= value;
      s.textContent = filled ? '★' : '☆';
      s.classList.toggle('filled', filled);
    });
  }

  function readForm() {
    const readRows = (containerId) => {
      const rows = Array.from($(containerId).querySelectorAll('.ingredient-row'));
      return rows.map(row => {
        const name = row.querySelector('.ing-name').value.trim();
        const amountRaw = row.querySelector('.ing-amount').value.trim();
        const unit = row.querySelector('.ing-unit').value.trim();
        const note = row.querySelector('.ing-note').value.trim();
        if (!name) return null;
        const parsed = parseAmount(amountRaw);
        return {
          name,
          amount: parsed,
          // If parse fails but text was provided, keep the descriptive text in the unit
          unit: parsed === null && amountRaw ? (amountRaw + (unit ? ' ' + unit : '')) : unit,
          note: note || undefined,
        };
      }).filter(Boolean);
    };

    const steps = Array.from($('step-rows').querySelectorAll('.step-text'))
      .map(t => t.value.trim())
      .filter(Boolean);

    const id = $('form-id').value || uid();
    const existing = state.recipes.find(r => r.id === id);

    return {
      id,
      name: $('form-name').value.trim(),
      rating: parseInt($('form-rating').dataset.value || '0', 10),
      category: $('form-category').value.trim(),
      source: $('form-source').value.trim(),
      servings: parseFloat($('form-servings').value) || 1,
      ingredients: readRows('ingredient-rows'),
      sauce: readRows('sauce-rows'),
      steps,
      notes: $('form-notes').value.trim(),
      createdAt: existing?.createdAt || Date.now(),
      updatedAt: Date.now(),
    };
  }

  // ---------- Render orchestration ----------
  function renderAll() {
    renderCategoryOptions();
    renderList();
  }

  // ---------- Event wiring ----------
  function init() {
    // Header
    $('back-btn').addEventListener('click', () => {
      if (state.view === 'form' && state.editingId) {
        state.selectedId = state.editingId;
        state.editingId = null;
        renderDetail();
        setView('detail');
      } else {
        state.editingId = null;
        setView('list');
      }
    });

    $('add-btn').addEventListener('click', () => renderForm(null));
    $('empty-add-btn').addEventListener('click', () => renderForm(null));

    // List interactions
    $('search-input').addEventListener('input', e => {
      state.search = e.target.value;
      renderList();
    });

    $('category-filter').addEventListener('change', e => {
      state.categoryFilter = e.target.value;
      renderList();
    });

    $('rating-filter').addEventListener('change', e => {
      state.ratingFilter = parseInt(e.target.value || '0', 10);
      renderList();
    });

    $('sort-select').addEventListener('change', e => {
      state.sort = e.target.value;
      renderList();
    });

    $('recipe-list').addEventListener('click', e => {
      const card = e.target.closest('.recipe-card');
      if (!card) return;
      state.selectedId = card.dataset.id;
      renderDetail();
      setView('detail');
    });

    $('recipe-list').addEventListener('keydown', e => {
      if (e.key !== 'Enter' && e.key !== ' ') return;
      const card = e.target.closest('.recipe-card');
      if (!card) return;
      e.preventDefault();
      state.selectedId = card.dataset.id;
      renderDetail();
      setView('detail');
    });

    // Detail
    $('serving-input').addEventListener('input', e => {
      const v = parseFloat(e.target.value);
      if (!Number.isNaN(v) && v > 0) {
        state.detailServings = v;
        const r = getRecipe(state.selectedId);
        if (r) renderIngredients(r);
      }
    });

    $('serving-minus').addEventListener('click', () => {
      const next = Math.max(0.5, (state.detailServings || 1) - 0.5);
      state.detailServings = next;
      $('serving-input').value = formatAmount(next);
      const r = getRecipe(state.selectedId);
      if (r) renderIngredients(r);
    });

    $('serving-plus').addEventListener('click', () => {
      const next = (state.detailServings || 1) + 0.5;
      state.detailServings = next;
      $('serving-input').value = formatAmount(next);
      const r = getRecipe(state.selectedId);
      if (r) renderIngredients(r);
    });

    $('edit-btn').addEventListener('click', () => {
      const r = getRecipe(state.selectedId);
      if (r) renderForm(r);
    });

    $('delete-btn').addEventListener('click', () => {
      const r = getRecipe(state.selectedId);
      if (!r) return;
      if (confirm(`"${r.name}" 레시피를 삭제할까요? 되돌릴 수 없습니다.`)) {
        deleteRecipe(r.id);
        state.selectedId = null;
        renderAll();
        setView('list');
      }
    });

    // Form
    $('form-rating').addEventListener('click', e => {
      const star = e.target.closest('span[data-star]');
      if (!star) return;
      const value = parseInt(star.dataset.star, 10);
      const current = parseInt($('form-rating').dataset.value || '0', 10);
      // Click the same star to clear it
      setRatingInput(value === current ? 0 : value);
    });

    $('add-ingredient').addEventListener('click', () => addIngredientRow(null, 'ingredient-rows'));
    $('add-sauce').addEventListener('click', () => addIngredientRow(null, 'sauce-rows'));
    $('add-step').addEventListener('click', () => addStepRow(''));

    $('cancel-btn').addEventListener('click', () => {
      if (state.editingId) {
        state.selectedId = state.editingId;
        state.editingId = null;
        renderDetail();
        setView('detail');
      } else {
        setView('list');
      }
    });

    $('recipe-form').addEventListener('submit', e => {
      e.preventDefault();
      const data = readForm();
      if (!data.name) {
        alert('레시피 이름을 입력해주세요.');
        return;
      }
      if (data.ingredients.length === 0) {
        alert('재료를 한 가지 이상 입력해주세요.');
        return;
      }
      if (data.steps.length === 0) {
        alert('만드는법을 한 단계 이상 입력해주세요.');
        return;
      }

      upsertRecipe(data);
      state.editingId = null;
      state.selectedId = data.id;
      renderAll();
      renderDetail();
      setView('detail');
    });

    renderAll();
    setView('list');
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
