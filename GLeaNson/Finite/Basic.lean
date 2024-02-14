import Mathlib.Order.Birkhoff
import Mathlib.Order.GaloisConnection

open LatticeHom Set

/-%%
In this file, we give a complete proof of Birkhoff Duality, that is:

the category of finite distributive lattices with homomorphisms
is dually equivalent to
the category of finite posets with monotone functions.

Throughout the file, let $L$ be a finite distributive lattice,
and $P$ a finite partial order.
%%-/

variable (L P : Type)
variable [DistribLattice L] [Fintype L]
variable [PartialOrder P] [Fintype P]

/-%%
\begin{definition}\label{join-irreducible}\lean{SupIrred}
An element $x$ of a finite distributive lattice $L$ is \emph{join-irreducible} if
$x \neq \bot$ and, for every $y, z \in L$ such that $x = y \vee z$, we have
$x = y$ or $x = z$.
\end{definition}

\begin{definition}\label{lower set}\lean{IsLowerSet}
A subset $S$ of a finite partial order $P$ is a \emph{lower set} (also known as \emph{down-set})
if any element that is less than a member of $S$ is also a member of $S$.
\end{definition}

The set of join-irreducible elements of $L$ is a finite poset, when equipped with the
partial order induced by the set of join-irreducible elements.
%%-/

example : PartialOrder {a : L // SupIrred a} := Subtype.partialOrder fun a ↦ SupIrred a

/-%%
The set of lower sets of $P$ is a finite distributive lattice, when equipped with the
operations of union and intersection.
%%-/

example : DistribLattice (LowerSet P) := by infer_instance

/-%%
The dual equivalence, modulo a category-theoretic fact that is already in Mathlib (TODO: find it),
comes down to the following two concrete facts about the assignment (functor) that sends the
finite distributive lattice L to the poset of join-irreducible elements:

First, the assignment is essentially surjective.
\begin{proposition}[Essential surjectivity]\label{EssSurjFinDL}\lean{OrderIso.supIrredLowerSet'}
The function from the poset $P$ to the poset of join-irreducible elements of the distributive
lattice of lower sets of $P$, which sends each $p \in P$ to the lower set generated by $p$,
is a well-defined isomorphism of partial orders.
\end{proposition}
%%-/

/- NB: there is a similar statement to the above proposition in Mathlib,
but it is not general enough, as it only treats
the case where P is a distributive lattice. But all that is needed is that P is a finite poset. -/
#check OrderIso.supIrredLowerSet

-- To prove Proposition~{EssSurjFinDL}, we will need:
-- A join-irreducible`SupIrred` element of the lattice of lower sets has a unique maximal element.
-- TODO is it in the library?
-- lemma maximalElementOfJoinIrreducibleLowerSet {s : LowerSet P} (h : SupIrred s) :
--   { m : P // m ∈ s ∧ ∀ (p : P), p ∈ s → p ≤ m } := by sorry

-- since s is LowerSet, it is a union of the lower sets generated by its maximal elements
-- lemma lowerSetGeneratedByMaxElements {s : LowerSet P} :
-- s = ⋃ { lowerClosure p | p ∈ max s } := sorry

noncomputable def topOfJoinIrreducibleLowerSet {s : LowerSet P} (h_irred : SupIrred s) : s := by
-- since s = union of {p} for p ranging over s,

-- lowerClosure s = lowerClosure (union of {p} for p ranging over s)
-- but s = lowerClosure s (since s is a LowerSet)
-- and the RHS can be expanded to:
-- union (lowerClosure {p}) for p ranging over s by a lemma in the library
-- but now s is supIrred so we get s = lowerclosure {p} for some p.

  haveI fins : Fintype s.1 := sorry
  -- we want to somewhere separate out this f because it is used several times.
  have f : P -> LowerSet P := fun p => lowerClosure {p}
  have seqsupf : Finset.sup s.1.toFinset f = s := sorry -- ⋁ f[s] = s
  have existsi := SupIrred.finset_sup_eq h_irred seqsupf

  -- TODO: here we had some trouble because the existsi term is not a Prop.
  -- TODO: we should also not need axiom of choice to choose an element in a finite set with 1 element!!!
  set x := existsi.choose with hx0
  have hx := existsi.choose_spec
  rw [←hx0] at hx
  use x
  simp_all
-- since s is LowerSet, it is a union of the lower sets generated by its maximal elements
-- since s is SupIrred, this union can only consist of a single set
-- the element generating that single set must be the top of s.

lemma topOfJILSisTop {s : LowerSet P} (h_irred : SupIrred s) :
  IsTop (topOfJoinIrreducibleLowerSet P h_irred) := sorry

-- NB most of the work above is in fact already done here:
-- #check LowerSet.supIrred_iff_of_finite
open LowerSet

-- This is `LowerSet.erase_sup_Iic` with the assumption on `P` relaxed
lemma foo1 (a : P) : SupIrred (LowerSet.Iic a) := by
  refine' ⟨fun h ↦ Iic_ne_bot h.eq_bot, fun s t hst ↦ _⟩
  have := mem_Iic_iff.2 (le_refl a)
  rw [← hst] at this
  exact this.imp (fun ha ↦ (le_sup_left.trans_eq hst).antisymm <| Iic_le.2 ha) fun ha ↦
    (le_sup_right.trans_eq hst).antisymm <| Iic_le.2 ha

-- This is `LowerSet.supIrred_iff_of_finite` with the assumption on `P` relaxed
lemma bar (s : LowerSet P) : SupIrred s ↔ ∃ a, LowerSet.Iic a = s := by
  refine' ⟨fun hs ↦ _, _⟩
  · obtain ⟨a, ha, has⟩ := (s : Set P).toFinite.exists_maximal_wrt id _ (coe_nonempty.2 hs.ne_bot)
    exact ⟨a, (hs.2 <| erase_sup_Iic ha <| by simpa [eq_comm] using has).resolve_left
      (erase_lt.2 ha).ne⟩
  · rintro ⟨a, rfl⟩
    apply foo1

def barUnique {s : LowerSet P} (hs : SupIrred s) : Unique {a // LowerSet.Iic a = s} where
  default := sorry
  uniq := sorry

--with `def` the following would have bad reduction properties
abbrev TopGuy {s : LowerSet P} (hs : SupIrred s) : P := (barUnique P hs).default.1

lemma TopUnique {s : LowerSet P} (hs : SupIrred s) (x : {a // LowerSet.Iic a = s}) :
  x = TopGuy P hs := by rw [(barUnique P hs).2 x]--probably there is some API for the `Unique` class that is nicers

lemma TopUnique_prop {s : LowerSet P} (hs : SupIrred s) : (LowerSet.Iic (TopGuy P hs)) = s := by
  rw [(barUnique P hs).default.2]


def Equiv.supIrredLowerSet' : P ≃ {s : LowerSet P // SupIrred s} where
  toFun := fun a ↦ ⟨LowerSet.Iic a, foo1 P a⟩
  invFun := fun ⟨s, hs⟩ ↦ TopGuy P hs
  left_inv := by
    sorry
  right_inv := by
    intro ⟨s, hs⟩
    simp only [Subtype.mk.injEq]
    exact TopUnique_prop P hs

-- TODO: Filippo will separate this into one definition for the equiv part and another for the order-iso part.
-- The proposition is then the following:
def OrderIso.supIrredLowerSet' : P ≃o {s : LowerSet P // SupIrred s} := by
  have f : P → LowerSet P := fun p => lowerClosure {p}
-- this f will in fact map into the right place, {s : LowerSet P // SupIrred s}, as follows from
-- LowerSet.supIrred_Iic
  have g : {s : LowerSet P // SupIrred s} → P := fun ⟨s, hs⟩ => (topOfJoinIrreducibleLowerSet P hs)
  -- TODO: show that f and g are an equivalence, and then:
  apply Equiv.toOrderIso


/-%%
Second, the assignment is a full and faithful functor. We break this up in a number of steps. Throughout the argument, let $L$ and $M$ be finite distributive lattices, and $h : L \to M$ a homomorphism between them.
%%-/

variable (M : Type) [DistribLattice M] [Fintype M]
variable (h : LatticeHom L M)

/-%%
(Note: what I would call an adjunction between posets is currently called a "Galois connection" in Mathlib - this choice of terminology is unusual.)
\begin{lemma}
Let $h : L \to M$ be a homomorphism between finite distributive lattices. Then there exists
a left adjoint $f : M \to L$ of $h$.
\end{lemma}
\begin{proof}
Since $L$ and $M$ are finite, they are complete. Now $h$ is a sup-preserving function,
so it has a left adjoint by the adjoint functor theorem (for complete lattices).
\end{proof}
%%-/

lemma leftAdjointExists : ∃ f : M → L, GaloisConnection f h := by sorry


/-%%
\begin{lemma}
Let $f$ be the left adjoint of $h$. For any join-irreducible $p$ of $M$, $f(p)$ is join-irreducible.
\end{lemma}
%%-/
lemma leftAdjointPreservesJoinIrreducible {f : M → L} {hfh : GaloisConnection f h}
  (p : M) (hp : SupIrred p) : SupIrred (f p) := by sorry


/-%%
\begin{proposition}[Fully faithful]\label{FullyFaithfulFinDL}
There is a bijection between the set of homomorphisms $L \to M$ and the set of monotone functions from the poset of join-irreducible elements of $M$ to the poset of join-irreducible elements of $L$.
\end{proposition}

Note that the bijection in the above proposition is even an order-isomorphism, which would be
needed if we wanted to establish a Poset-enriched dual equivalence of categories. But it is not
automatic in Mathlib that LatticeHom L M is a poset, so we do not state this stronger result here.
%%-/

theorem FullyFaithfulFinDL : (LatticeHom L M) ≃ ({a : M // SupIrred a} →o {a : L // SupIrred a})
  := by sorry

/-%%
After proving the above theorems, what remains to be done to formally establish Birkhoff duality
is the application of the category-theoretic fact that any functor that is essentially surjective,
full, and faithful is an equivalence of categories. This is a standard result in category theory,
and is already in Mathlib somewhere.
TODO: where?
%%-/
