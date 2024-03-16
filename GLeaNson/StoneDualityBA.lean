import Mathlib.Topology.Category.Profinite.Basic
import Mathlib.Order.Category.BoolAlg

open CategoryTheory TopologicalSpace

open scoped Classical

namespace StoneDuality

@[simps obj]
def Clp : Profiniteᵒᵖ ⥤ BoolAlg where
  obj S := BoolAlg.of (Clopens S.unop)
  map f := by
    refine ⟨⟨⟨fun s ↦ ⟨f.unop ⁻¹' s.1, IsClopen.preimage s.2 f.unop.2⟩, ?_⟩, ?_⟩, ?_, ?_⟩
    all_goals intros; congr

@[simp] -- the one generated by `simps` was too ugly
lemma Clp_map_toLatticeHom_toSupHom_toFun_coe {X Y : Profiniteᵒᵖ} (f : X ⟶ Y) (s : Clopens X.unop) :
  (Clp.map f s).carrier = f.unop ⁻¹' s.carrier := by rfl

namespace Spec

open BoolAlg

variable (A : BoolAlg)

def basis : Set (Set (A ⟶ of Prop)) :=
  let U : A → Set (A ⟶ of Prop) := fun a ↦ {x | x.1 a = ⊤}
  Set.range U

instance instTopHomBoolAlgProp : TopologicalSpace (A ⟶ of Prop) := generateFrom <| basis A
  --induced (fun f ↦ (f : A → Prop)) (Pi.topologicalSpace (t₂ := fun _ ↦ ⊥))

theorem basis_is_basis : IsTopologicalBasis (basis A) where
  exists_subset_inter := by
    rintro t₁ ⟨a₁, rfl⟩ t₂ ⟨a₂, rfl⟩ x hx
    simp only [BddDistLat.coe_toBddLat, coe_toBddDistLat, coe_of, eq_iff_iff, Set.mem_inter_iff,
      Set.mem_setOf_eq] at hx
    refine ⟨{x | x.1.1.1 (a₁ ⊓ a₂) = ⊤}, ⟨(a₁ ⊓ a₂), rfl⟩, ?_, ?_⟩
    · simp only [BddDistLat.coe_toBddLat, coe_toBddDistLat, coe_of, eq_iff_iff, Set.mem_setOf_eq]
      rw [x.map_inf']
      tauto
    · intro y (hy : y.1.1.1 _ = ⊤)
      rw [y.map_inf'] at hy
      simp only [BddDistLat.coe_toBddLat, coe_toBddDistLat, coe_of, inf_Prop_eq, eq_iff_iff] at hy
      simp only [BddDistLat.coe_toBddLat, coe_toBddDistLat, coe_of, eq_iff_iff, Set.mem_inter_iff,
        Set.mem_setOf_eq]
      tauto
  sUnion_eq := by
    rw [Set.sUnion_eq_univ_iff]
    intro x
    simp only [basis, BddDistLat.coe_toBddLat, coe_toBddDistLat, coe_of, eq_iff_iff, Set.mem_range,
      exists_exists_eq_and, Set.mem_setOf_eq]
    exact ⟨⊤, eq_iff_iff.mp x.2⟩
  eq_generateFrom := rfl

noncomputable def emb : (A ⟶ of Prop) → (A → Bool) := fun f a ↦ decide (f a)


-- TODO: Check that with
-- attribute [-instance] sierpinskiSpace
-- def discreteProp : TopologicalSpace Prop := sorry
-- the following might replace `emb` still being continuous
def emb' : (A ⟶ of Prop) → (A → Prop) := (·)

instance (A : BoolAlg) : BooleanAlgebra ((forget BoolAlg).obj A) :=
  (inferInstance : BooleanAlgebra A)

instance (A B : BoolAlg) : BoundedLatticeHomClass (A ⟶ B) A B :=
  (inferInstance : BoundedLatticeHomClass (BoundedLatticeHom A B) A B)

instance (A B : BoolAlg) :
    BoundedLatticeHomClass (A ⟶ B) A ((forget BoolAlg).obj B) :=
  (inferInstance : BoundedLatticeHomClass (BoundedLatticeHom A B) A B)

instance (A B : BoolAlg) :
    BoundedLatticeHomClass (A ⟶ B) ((forget BoolAlg).obj A) B :=
  (inferInstance : BoundedLatticeHomClass (BoundedLatticeHom A B) A B)

instance (A B : BoolAlg) :
    BoundedLatticeHomClass (A ⟶ B) ((forget BoolAlg).obj A) ((forget BoolAlg).obj B) :=
  (inferInstance : BoundedLatticeHomClass (BoundedLatticeHom A B) A B)

theorem continuous_emb : Continuous (emb A) := by
  apply continuous_pi
  intro a
  simp only [emb, BddDistLat.coe_toBddLat, coe_toBddDistLat, coe_of]
  rw [continuous_discrete_rng]
  rintro ⟨⟩
  · refine (basis_is_basis A).isOpen ⟨aᶜ, ?_⟩
    ext x
    have hc := map_compl' x a
    rw [eq_iff_iff, compl_iff_not] at hc -- why doesn't `simp` work?
    simpa [Prop.top_eq_true] using hc
  · refine (basis_is_basis A).isOpen ⟨a, ?_⟩
    ext x
    simp only [BddDistLat.coe_toBddLat, coe_toBddDistLat, coe_of, Prop.top_eq_true, eq_iff_iff,
      iff_true, Set.mem_setOf_eq, Set.mem_preimage, Set.mem_singleton_iff, decide_eq_true_eq]
    rfl

theorem inducing_emb : Inducing (emb A) where
  induced := by
    refine eq_of_ge_of_not_gt (le_generateFrom fun s hs ↦ ?_)
        (not_lt_of_le (continuous_emb _).le_induced)
    rw [isOpen_induced_iff]
    obtain ⟨a, rfl⟩ := hs
    refine ⟨Set.pi {a} fun _ ↦ {true}, ?_, ?_⟩
    · exact isOpen_set_pi (Set.finite_singleton _) fun _ _ ↦ trivial
    · ext x
      simp only [Bool.univ_eq, Set.singleton_pi, ↓reduceIte, Set.mem_preimage, Function.eval, emb,
        Set.mem_singleton_iff, decide_eq_true_eq, BddDistLat.coe_toBddLat, coe_toBddDistLat,
        coe_of, Prop.top_eq_true, eq_iff_iff, iff_true, Set.mem_setOf_eq]
      rfl

/- When Y is a T2 space with a continuous binary operation and X is a set with a binary operation,
  the set of functions from X to Y that preserve the operation is closed as a subspace of X → Y. -/
theorem IsClosed_PreserveBinary_T2 [TopologicalSpace Y] [T2Space Y] (x₁ x₂ : X) (oX : X → X → X)
 (oY : Y → Y → Y) (hcts : Continuous (fun (y₁,y₂) ↦ oY y₁ y₂)) :
 IsClosed { f : X → Y | f (oX x₁ x₂) = oY (f x₁) (f x₂)} := by
    let g2 (f : X → Y) := oY (f x₁) (f x₂)
    let g (f : X → Y) := (f (oX x₁ x₂), g2 f)
    have : { f : X → Y | f (oX x₁ x₂) = oY (f x₁) (f x₂)} = g⁻¹' (Set.diagonal Y) := by ext x; simp
    rw [this]
    let k (f : X → Y) := (f x₁, f x₂)
    have kcts : Continuous k := by continuity --or: by simp [continuous_prod_mk, continuous_apply]
    have g2cts : Continuous g2 := Continuous.comp hcts kcts
    exact IsClosed.preimage (by continuity) isClosed_diagonal

/- Proof sketch of what is happening above:
  When x ∈ X, I write π_x for the x-coordinate projection map (X → Y) → Y.
  Note that the set in question can be written as
  g⁻¹ (Δ)
  where Δ is the diagonal in Y × Y, which is closed because Y is T2.
  g is the function (X → Y) → (Y × Y) defined by
  g(f) := (f (oX x₁ x₂), oY (f x₁) (f x₂)).
  And g is continuous because each component is:
  the first component is equal to π_x where x := oX x₁ x₂
  and the second component is the composite oY ∘ ⟨π_(x₁), π_(x₂)⟩.
  [NB: I had to do some hacking with currying oY, sometimes we want it to have type
  Y → Y → Y (like when we apply it below) and sometimes type Y × Y → Y (like when we reason about
  the diagonal as a closed subset of Y × Y). This can probably be improved.]
-/

theorem IsClosed_PreserveNullary_T1 [TopologicalSpace Y] [T1Space Y] (x : X) (y : Y) :
  IsClosed { f : X → Y | f x = y } := by
    let evx (f : X → Y) := f x
    have : IsClosed (evx⁻¹' {y}) := IsClosed.preimage (by continuity) (by simp [T1Space.t1 y])
    exact this

theorem closedEmbedding_emb : ClosedEmbedding (emb A) := by
  refine closedEmbedding_of_continuous_injective_closed ?_ ?_ ?_
  · exact continuous_emb _
  · intro _ _ h
    ext
    rw [eq_iff_iff]
    simpa [emb] using congrFun h _
  · refine (inducing_emb _).isClosedMap ?_
    let J : A → A → (Set (A → Bool)) := fun a b ↦ {x | x (a ⊔ b) = (x a ∨ x b)}
    let I : A → A → (Set (A → Bool)) := fun a b ↦ {x | x (a ⊓ b) = (x a ∧ x b)}
    let T : Set (A → Bool) := {x | x ⊤ = true}
    let B : Set (A → Bool) := {x | x ⊥ = false}
    have : Set.range (emb A) = (⋂ (a : A) (b : A), J a b) ∩ (⋂ (a : A) (b : A), I a b) ∩ T ∩ B := by
      ext x
      constructor
      · rintro ⟨x, rfl⟩
        simp only [Bool.decide_coe, Set.mem_inter_iff,
          Set.mem_iInter, Set.mem_setOf_eq, emb, map_sup, map_inf, map_top, decide_eq_true_eq,
          map_bot, decide_eq_false_iff_not]
        rw [Prop.top_eq_true, Prop.bot_eq_false]
        simp only [and_true, not_false_eq_true]
        refine ⟨fun a b ↦ ?_, fun a b ↦ ?_⟩
        all_goals congr
      · intro ⟨⟨⟨h_map_sup, h_map_inf⟩, h_map_top⟩, h_map_bot⟩
        refine ⟨⟨⟨⟨fun a ↦ (x a : Prop), ?_⟩, ?_⟩, ?_, ?_⟩, ?_⟩
        · simp only [Set.mem_iInter, Set.mem_setOf_eq] at h_map_sup
          simp [h_map_sup]
        · simp only [Set.mem_iInter, Set.mem_setOf_eq] at h_map_inf
          simp [h_map_inf]
        · simpa [Prop.top_eq_true] using h_map_top
        · simpa [Prop.bot_eq_false] using h_map_bot
        · ext a
          simp only [emb, BddDistLat.coe_toBddLat, coe_toBddDistLat, coe_of]
          have : (decide (x a = true)) = x a := by simp only [Bool.decide_coe]
          rw [← this]
          congr
    rw [this]
    refine IsClosed.inter (IsClosed.inter (IsClosed.inter ?_ ?_) ?_) ?_
    · refine isClosed_iInter (fun i ↦ isClosed_iInter (fun j ↦ ?_))
      simp only [Bool.decide_or, Bool.decide_coe]
      exact (IsClosed_PreserveBinary_T2 i j (Sup.sup) (or) (by continuity))
    · refine isClosed_iInter (fun i ↦ isClosed_iInter (fun j ↦ ?_))
      simp only [Bool.decide_and, Bool.decide_coe]
      exact (IsClosed_PreserveBinary_T2 i j (Inf.inf) (and) (by continuity))
    · exact (IsClosed_PreserveNullary_T1 ⊤ true)
    · exact (IsClosed_PreserveNullary_T1 ⊥ false)

instance : CompactSpace (A ⟶ of Prop) := sorry

instance : T2Space (A ⟶ of Prop) := sorry

instance : TotallyDisconnectedSpace (A ⟶ of Prop) := sorry

end Spec

open Spec

theorem Spec_map_cont {X Y : BoolAlg} (f : Y ⟶ X) :
    Continuous fun (y : X ⟶ BoolAlg.of Prop) ↦ f ≫ y := by
  rw [continuous_generateFrom_iff]
  rintro _ ⟨a, rfl⟩
  exact isOpen_generateFrom_of_mem ⟨f a, rfl⟩

@[simps]
def Spec : BoolAlgᵒᵖ ⥤ Profinite where
  obj A := Profinite.of (A.unop ⟶ BoolAlg.of Prop)
  map f := ⟨fun y ↦ f.unop ≫ y, Spec_map_cont f.unop⟩


def Equiv : Profinite ≌ BoolAlgᵒᵖ where
  functor := Clp.rightOp
  inverse := Spec
  unitIso := sorry
  counitIso := sorry
  functor_unitIso_comp := sorry

end StoneDuality
