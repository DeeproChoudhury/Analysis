import data.real.basic

/-!

# Q3 

Take bounded, nonempty `S, T ⊆ ℝ`.
Define `S + T := { s + t : s ∈ S, t ∈ T}`.
Prove `sup(S + T) = sup(S) + sup(T)`

-/

-- useful for rewriting
theorem is_lub_def {S : set ℝ} {a : ℝ} :
  is_lub S a ↔ a ∈ upper_bounds S ∧ ∀ x, x ∈ upper_bounds S → a ≤ x :=
begin
  refl
end

#check mem_upper_bounds -- a ∈ upper_bounds S ↔ ∀ x, x ∈ S → x ≤ a

/-
Useful tactics for this one: push_neg, specialize, have
-/
theorem useful_lemma {S : set ℝ} {a : ℝ} (haS : is_lub S a) (t : ℝ)
  (ht : t < a) : ∃ s, s ∈ S ∧ t < s :=
begin
  by_contradiction,
  push_neg at h,
  rw is_lub_def at haS,
  rw ← mem_upper_bounds at h,
  cases haS with h1 h2,
  specialize h2 t h,
  linarith,
end

/-
Useful tactics for this one:
`rcases h with ⟨s, t, hsS, htT, rfl⟩` if h : x ∈ S + T
`linarith`
`by_contra`
`set ε := a + b - x with hε`
-/
theorem Q3 (S T : set ℝ) (a b : ℝ) :
  is_lub S a → is_lub T b → is_lub (S + T) (a + b) :=
begin
  intros h1 h2,
  have h1':=h1,
  have h2':=h2,
  cases h1 with h3 h4,
  cases h2 with h5 h6,
  rw is_lub_def,
  rw mem_lower_bounds at *,
  rw mem_upper_bounds at *,
  split;
  intros x h8,
  rcases h8 with ⟨ s,t,hsS,htT,rfl⟩,
  specialize h5 t,
  specialize h3 s,
  have htb:= h5 htT,
  have hsa:= h3 hsS,
  linarith,

  rw mem_upper_bounds at *,
  by_contradiction,
  push_neg at h,
  set ε := a + b - x with hε,
  have h9: a - ε / 100 <a,
  linarith,
  have hb: b - ε / 100<b,
  linarith,
  have h10:= useful_lemma h1' (a-ε/100) _,
  rcases h10 with ⟨s, hs1, hs2⟩,
  have h11:= useful_lemma h2' (b-ε/100) _,
  rcases h11 with ⟨t, ht1, ht2⟩,
  specialize h5 t,
  specialize h3 s,
  have htb:= h5 ht1,
  have hsa:= h3 hs1,
  specialize h8 (s+t),
  have hst: s + t ∈ S + T,
  split,
  use t,
  split,
  assumption,
  split,
  assumption,
  refl,
  have h11:= h8 hst,
  linarith,
  linarith,
  linarith,
end

/-!

# Q6

-/

-- We introduce the usual mathematical notation for absolute value
local notation `|` x `|` := abs x

/-
Useful for this one: `unfold`, `split_ifs` if you want to prove
from first principles, or guessing the name of the library function
if you want to use the library.
-/
theorem Q6a (x y : ℝ) : | x + y | ≤ | x | + | y | :=
begin
  exact abs_add x y,
end

-- all the rest you're supposed to do using Q6a somehow:
-- `simp` and `linarith` are useful.

theorem Q6b (x y : ℝ) : |x + y| ≥ |x| - |y| :=
begin
  have h:= Q6a,
  rw ge_iff_le,
  specialize h (x+y) (-y),
  simp at h,
  linarith,
end

theorem Q6c (x y : ℝ) : |x + y| ≥ |y| - |x| :=
begin
  have h:= Q6a,
  rw ge_iff_le,
  specialize h (-x) (x+y),
  simp at h,
  linarith,
end

theorem Q6d (x y : ℝ) : |x - y| ≥ | |x| - |y| | :=
begin
  rw ge_iff_le,
  have h: |x| -|y|<0 ∨ 0≤ |x| - |y|,
  exact lt_or_ge _ 0,
  cases h,
  rw abs_of_neg h,
  simp,
  have h2:= Q6c,
  specialize h2 x (-y),
  simp at h2,
  have h3: x+-y = x-y,
  ring,
  rwa h3 at h2,
  rw abs_of_nonneg h,
  have h2:= Q6c,
  specialize h2 y (-x),
  simp at h2,
  ring at h2,
  exact abs_sub_abs_le_abs_sub x y,
end

theorem Q6e (x y : ℝ) : |x| ≤ |y| + |x - y| :=
begin
  have h2:= Q6a,
  specialize h2 (x-y) (y),
  ring at h2,
  linarith,
end

theorem Q6f (x y : ℝ) : |x| ≥ |y| - |x - y| :=
begin
  have h2:= Q6a,
  rw ge_iff_le,
  specialize h2 x (y-x),
  ring at h2,
  have h3: abs(x-y) = abs(y-x),
  apply abs_sub x y,
  rw h3,
  linarith,
end

theorem Q6g (x y z : ℝ) : |x - y| ≤ |x - z| + |y - z| :=
begin
  have h2:=Q6a,
  specialize h2 (x-z) (z-y),
  ring at h2,
  have h3: abs(y-z) = abs(z-y),
  apply abs_sub y z,
  rwa h3,
end



/-!

# Q4

NOTE: I have not done this one myself -- some lemmas could be wrong!
I just copied directly from the problem sheet and you know how
sloppy mathematicians are...


Fix `a ∈ (0,∞)` and `n : ℕ`. We will prove
`∃ x : ℝ, x^n = a`. 

-/

section Q4

noncomputable theory

parameters {a : ℝ} (ha : 0 < a) {n : ℕ} (hn : 0 < n)

/-
1) Set `Sₐ := {s ∈ [0,∞) : s^n < a}` and show `Sₐ` is nonempty and
bounded above, so we may define `x := sup Sₐ`.
-/

def S := {s : ℝ | 0 ≤ s ∧ s ^ n < a}

include ha hn

theorem part1 : (∃ s : ℝ, s ∈ S) ∧ (∃ B : ℝ, ∀ s ∈ S, s ≤ B ) :=
sorry

def x := Sup S

-- the sup is the least upper bound
theorem is_lub_x : is_lub S x :=
begin
  cases part1 with nonempty bdd,
  cases nonempty with x hx,
  cases bdd with y hy,
  exact real.is_lub_Sup hx hy,
end

/-
2) For `ε ∈ (0,1)` show `(x+ε)ⁿ ≤ x^n + ε[(x + 1)ⁿ − xⁿ].`
(Hint: multiply out.)
-/

-- I'm pretty sure this is needed
lemma x_nonneg : 0 ≤ x :=
begin
  rcases is_lub_x with ⟨h, -⟩,
  apply h,
  split, refl,
  convert ha,
  simp [hn],
end

theorem part2 (ε : ℝ) (hε0 : 0 < ε) (hε1 : ε < 1) : (x + ε)^n ≤ x^n + ε*((x+1)^n - x^n) :=
begin
  sorry
end

/-
3) Hence show that if `xⁿ < a` then
`∃ ε ∈ (0,1)` such that `(x+ε)ⁿ < a.` (*)
-/

theorem part3 (h : x ^ n < a) : ∃ ε : ℝ, 0 < ε ∧ ε < 1 ∧ (x+ε)^n < a :=
begin
  sorry
end

/-
4) If `xⁿ > a`, deduce from (∗) that
`∃ ε ∈ (0,1)` such that `(1/x+ε)ⁿ < 1/a`. (∗∗)
-/

-- part 4 doesn't quite make sense because we didn't show x ≠ 0 yet

lemma easy (h : a < x^n) : x ≠ 0 :=
begin
  intro hx,
  rw hx at h,
  suffices : a < 0,
    linarith,
  convert h,
  symmetry, -- ??
  simp [hn],
end

theorem part4 (h : a < x^n) : ∃ ε : ℝ, 0 < ε ∧ ε < 1 ∧ (1/x + ε)^n < 1/a :=
begin
  sorry
end

/-
5) Deduce contradictions from (∗) and (∗∗) to show that `xⁿ = a`.
-/

theorem part5 : x^n = a :=
begin
  sorry
end

end Q4