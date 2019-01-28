{-# OPTIONS --without-K #-}

{-

Shallow formalization for the paper "Syntax for Higher Inductive-Inductive Types".

  * We shallowly embed both source and target theories into Agda. So, types become Agda types, functions
    Agda functions, and so on. Hence, the -ᴬ interpretation is left implicit everywhere.
  * For each ᴰ and ˢ translation case, we build and Agda function which constructs the translation result
    assuming all induction hypotheses.
  * The translations here are understood to be defined using recursion (as opposed to induction),
    so elements of the source syntax never even appear in this formalisation, and ᶜ is also implicit.
  * Dependency of Γ;Γ context are also left implicit. We model terms in extended contexts (such as the
    B domain of a ((x : a) → B) type) by Agda functions which take as arguments all additional context entries.
    Hence, if we are in implicit Γ context, and (Γ, x : El a ⊢ B), then we use (Bᴰ : (x : El a)(xᴰ : (El a)ᴰ x) → Uᴰ B)
-}

-- Definitions & shorthands in target theory
--------------------------------------------------------------------------------

open import Relation.Binary.PropositionalEquality renaming (_≡_ to Id)
open import Data.Product

_≡_ = Id
infix 4 _≡_

J : ∀ {α β}{A : Set α}{a : A}(B : ∀ b → a ≡ b → Set β) → B a refl → ∀ {b} p → B b p
J B pr refl = pr

_◾_ = trans
infixr 5 _◾_
ap = cong
_⁻¹ = sym

{-# DISPLAY sym x = x ⁻¹ #-}
{-# DISPLAY trans p q = p ◾ q #-}
{-# DISPLAY cong = ap #-}

tr : ∀ {α β}{A : Set α}{a b : A}(B : A → Set β) → a ≡ b → B a → B b
tr B eq t = J (λ u p → B u) t eq

apd : ∀ {α β}{A : Set α}(B : A → Set β)(f : ∀ a → B a)(x y : A)(p : x ≡ y) → tr B p (f x) ≡ f y
apd B f t u p = J (λ u p → tr B p (f t) ≡ f u) refl p

Π : (A : Set)(B : A → Set) → Set
Π A B = (x : A) → B x

inv : ∀ {α}{A : Set α}{x y : A}(p : x ≡ y) → (p ⁻¹) ◾ p ≡ refl
inv = J (λ _ p → (p ⁻¹) ◾ p ≡ refl) refl

--------------------------------------------------------------------------------

U = Set

-- non-inductive function space
Πₙᵢ  = Π

-- small non-inductive (infinitary) function space
Πₙᵢₛ = Π


--------------------------------------------------------------------------------
-- Displayed algebras
--------------------------------------------------------------------------------

Setᴰ : ∀ {i} → Set i → Set _
Setᴰ {i} A = A → Set i

Uᴰ : Set → Set₁
Uᴰ A = A → Set

Elᴰ : ∀{a}(aᴰ : Uᴰ a) → Setᴰ a -- Elᴰ is identity, so it is left implicit from now on
Elᴰ aᴰ x = aᴰ x

-- inductive functions
Πᴰ : ∀ {a}(aᴰ : Uᴰ a){B : a → Set}(Bᴰ : ∀ {x} (xₘ : aᴰ x) → Setᴰ (B x)) → Setᴰ (Π a B)
Πᴰ {a} aᴰ {B} Bᴰ f = (x : a)(xₘ : aᴰ x) → Bᴰ xₘ (f x)

appᴰ :
  ∀ {a}(aᴰ : Uᴰ a){B : a → Set}(Bᴰ : ∀ {x}(xₘ : aᴰ x) → Setᴰ (B x))
    {t : Π a B}(tᴰ : Πᴰ aᴰ Bᴰ t){u : a} (uᴰ : aᴰ u)
  → Bᴰ uᴰ (t u)
appᴰ {a} aᴰ {B} Bᴰ {t} tᴰ {u} uᴰ = tᴰ u uᴰ

-- non-inductive functions
Πₙᵢᴰ : (A : Set){B : A → Set}(Bᴰ : ∀ a → Setᴰ (B a)) → Setᴰ (Π A B)
Πₙᵢᴰ A {B} Bᴰ f = ∀ a → Bᴰ a (f a)

appₙᵢᴰ :
  ∀ (A : Set)
    {B : A → Set}  (Bᴰ : ∀ a → Setᴰ (B a))
    {t : Πₙᵢ A B}  (tᴰ : Πₙᵢᴰ A Bᴰ t)
    (u : A)
  → Bᴰ u (t u)
appₙᵢᴰ A {B} Bᴰ {t} tᴰ u = tᴰ u

-- small non-inductive functions (infinitary parameters)
Πₙᵢₛᴰ : (A : Set){b : A → U}(Bᴰ : ∀ a → Uᴰ (b a)) → Uᴰ (Πₙᵢₛ A b)
Πₙᵢₛᴰ A {B} bᴰ = λ f → ∀ a → bᴰ a (f a)

appₙᵢₛᴰ :
  ∀ (A : Set)
    {b : A → Set}  (bᴰ : ∀ a → Uᴰ (b a))
    {t : Πₙᵢₛ A b} (tᴰ : Πₙᵢₛᴰ A bᴰ t)
    (u : A)
  → bᴰ u (t u)
appₙᵢₛᴰ A {B} _ {t} tᴰ u = tᴰ u


-- Identity
≡ᴰ :
  {a : U} (aᴰ : Uᴰ a)
  {t : a} (tᴰ : aᴰ t)
  {u : a} (uᴰ : aᴰ u)
  → Uᴰ (t ≡ u)
≡ᴰ {a} aᴰ {t} tᴰ {u} uᴰ = λ z → tr aᴰ z tᴰ ≡ uᴰ

reflᴰ :
  {a : U} (aᴰ : Uᴰ a)
  {t : a} (tᴰ : aᴰ t)
  → (≡ᴰ aᴰ tᴰ tᴰ) refl
reflᴰ {a} aᴰ {t} tᴰ = refl {x = tᴰ}

Jᴰ :
  (a  : U)                  (aᴰ  : Uᴰ a)
  (t  : a)                  (tᴰ  : aᴰ t)
  (p  : ∀ x (z : t ≡ x) → U)(pᴰ  : ∀ x (xₘ : aᴰ x) z zₘ → Uᴰ (p x z))
  (pr : p t refl)           (prᴰ : pᴰ _ tᴰ _ (reflᴰ aᴰ tᴰ) pr)
  (u  : a)                  (uᴰ  : aᴰ u)
  (eq : t ≡ u)              (eqᴰ : (≡ᴰ aᴰ tᴰ uᴰ) eq)
  → pᴰ _ uᴰ _ eqᴰ (J p pr eq)
Jᴰ a aᴰ t tᴰ p pᴰ pr prᴰ u uᴰ eq eqᴰ =
  J (λ xᴰ zᴰ → pᴰ u xᴰ eq zᴰ (J p pr eq))
    (J (λ x z → pᴰ x (tr aᴰ z tᴰ) z refl (J p pr z))
      prᴰ eq)
    eqᴰ

Jβᴰ :
  {a  : U}                   (aᴰ  : Uᴰ a)
  {t  : a}                   (tᴰ  : aᴰ t)
  {p  : ∀ x (z : t ≡ x) → U} (pᴰ  : ∀ x (xₘ :  aᴰ x) z zₘ → Uᴰ (p x z))
  {pr : p t refl}            (prᴰ : pᴰ _ tᴰ _ (reflᴰ aᴰ tᴰ) pr)
  → ≡ᴰ (pᴰ t tᴰ refl refl) (Jᴰ _ _ _ _ _ pᴰ _ prᴰ _ tᴰ refl refl) prᴰ refl -- Note: this last refl is Jβᶜ
Jβᴰ _ _ _ _ = refl

-- Homomorphisms
--------------------------------------------------------------------------------

-- -- Universe

Setᴹ : (A₀ A₁ : Set) → Set₁
Setᴹ A₀ A₁ = A₀ → A₁ → Set

Uᴹ : (a₀ a₁ : Set) → Set
Uᴹ a₀ a₁ = a₀ → a₁

Elᴹ : {a₀ a₁ : U}(aᴹ : Uᴹ a₀ a₁) → Setᴹ a₀ a₁
Elᴹ aᴹ x₀ x₁ = aᴹ x₀ ≡ x₁

-- Inductive functions
Πᴹ : {a₀ a₁ : U} (aᴹ : Uᴹ a₀ a₁)
     {B₀ : a₀ → Set}{B₁ : a₁ → Set}(Bᴹ : ∀ {x₀ x₁}(xᴹ : Elᴹ aᴹ x₀ x₁) → Setᴹ (B₀ x₀) (B₁ x₁))
     → Setᴹ (Π a₀ B₀) (Π a₁ B₁)
Πᴹ {a₀} {a₁} aᴹ {B₀} {B₁} Bᴹ f₀ f₁ = (x₀ : a₀) → Bᴹ refl (f₀ x₀)(f₁ (aᴹ x₀))

appᴹ :
  {a₀ : U}        {a₁ : U}        (aᴹ : Uᴹ a₀ a₁)
  {B₀ : a₀ → Set} {B₁ : a₁ → Set} (Bᴹ : ∀ {x₀ x₁}(xᴹ : Elᴹ aᴹ x₀ x₁) → Setᴹ (B₀ x₀) (B₁ x₁))
  {t₀ : Π a₀ B₀}  {t₁ : Π a₁ B₁}  (tᴹ : Πᴹ aᴹ Bᴹ t₀ t₁)
  {u₀ : a₀}       {u₁ : a₁}       (uᴹ : Elᴹ aᴹ u₀ u₁)
  → Bᴹ uᴹ (t₀ u₀) (t₁ u₁)
appᴹ {a₀} {a₁} aᴹ {B₀} {B₁} Bᴹ {t₀} {t₁} tᴹ {u₀} {u₁} uᴹ =
  J (λ u₁ uᴹ → Bᴹ uᴹ (t₀ u₀) (t₁ u₁)) (tᴹ u₀) uᴹ

-- non-inductive functions
Πₙᵢᴹ :
  (A : Set)
  {B₀ B₁ : A → Set} (Bᴹ : ∀ a → Setᴹ (B₀ a) (B₁ a))
  → Setᴹ (Πₙᵢ A B₀) (Πₙᵢ A B₁)
Πₙᵢᴹ A Bᴹ f₀ f₁ = ∀ x → Bᴹ x (f₀ x) (f₁ x)

appₙᵢᴹ :
  (A : Set)
  {B₀ B₁ : A → Set} (Bᴹ : ∀ a → Setᴹ (B₀ a) (B₁ a))
  {t₀ : Πₙᵢ A B₀}{t₁ : Πₙᵢ A B₁}(tᴹ : Πₙᵢᴹ A Bᴹ t₀ t₁)
  (a : A)
  → Bᴹ a (t₀ a) (t₁ a)
appₙᵢᴹ A Bᴹ tᴹ a = tᴹ a

-- Small non-inductive functions
Πₙᵢₛᴹ :
  (A : Set)
  {b₀ b₁ : A → U}(bᴹ : ∀ a → Uᴹ (b₀ a) (b₁ a))
  → Uᴹ (Πₙᵢₛ A b₀) (Πₙᵢₛ A b₁)
Πₙᵢₛᴹ A bᴹ = λ f a → bᴹ a (f a)

appₙᵢₛᴹ :
  (A : Set)
  {b₀ b₁ : A → U}(bᴹ : ∀ a → Uᴹ (b₀ a) (b₁ a))
  {t₀ : Πₙᵢₛ A b₀}{t₁ : Πₙᵢₛ A b₁}(tᴹ : Elᴹ (Πₙᵢₛᴹ A bᴹ) t₀ t₁)
  (a : A)
  → Elᴹ (bᴹ a) (t₀ a) (t₁ a)
appₙᵢₛᴹ A bᴹ tᴹ a = ap (λ f → f a) tᴹ

-- Identity
≡ᴹ :
  {a₀ : U }{a₁ : U } (aᴹ : Uᴹ a₀ a₁)
  {t₀ : a₀}{t₁ : a₁} (tᴹ : Elᴹ aᴹ t₀ t₁)
  {u₀ : a₀}{u₁ : a₁} (uᴹ : Elᴹ aᴹ u₀ u₁)
  → Uᴹ (t₀ ≡ u₀) (t₁ ≡ u₁)
≡ᴹ {a₀} {a₁} aᴹ {t₀} {t₁} tᴹ {u₀} {u₁} uᴹ = λ e → (tᴹ ⁻¹) ◾ ap aᴹ e ◾ uᴹ

reflᴹ :
  {a₀ : U }{a₁ : U } (aᴹ : Uᴹ a₀ a₁)
  {t₀ : a₀}{t₁ : a₁} (tᴹ : Elᴹ aᴹ t₀ t₁)
  → Elᴹ (≡ᴹ aᴹ tᴹ tᴹ) refl refl
reflᴹ aᴹ tᴹ = inv tᴹ

Jᴹ :
  {a₀  : U}                         {a₁  : U}
  {t₀  : a₀}                        {t₁  : a₁}
  {p₀  : (x : a₀)(z : t₀ ≡ x) → U}  {p₁  : (x : a₁)(z : t₁ ≡ x) → U}
  {pr₀ : p₀ t₀ refl}                {pr₁ : p₁ t₁ refl}
  {u₀  : a₀}                        {u₁  : a₁}
  {eq₀ : t₀ ≡ u₀}                   {eq₁ : t₁ ≡ u₁}

  (aᴹ : Uᴹ a₀ a₁)
  (tᴹ : Elᴹ aᴹ t₀ t₁)
  (pᴹ : ∀ {x₀ x₁}(xᴹ : Elᴹ aᴹ x₀ x₁){z₀ : t₀ ≡ x₀}{z₁ : t₁ ≡ x₁}(tᴹ : Elᴹ (≡ᴹ aᴹ tᴹ xᴹ) z₀ z₁)
        → Uᴹ (p₀ x₀ z₀) (p₁ x₁ z₁))
  (prᴹ : Elᴹ (pᴹ tᴹ (reflᴹ aᴹ tᴹ)) pr₀ pr₁)
  (uᴹ  : Elᴹ aᴹ u₀ u₁)
  (eqᴹ : Elᴹ (≡ᴹ aᴹ tᴹ uᴹ) eq₀ eq₁)

  → Elᴹ (pᴹ uᴹ eqᴹ) (J p₀ pr₀ eq₀) (J p₁ pr₁ eq₁)
Jᴹ {a₀} {a₁} {t₀} {t₁} {p₀} {p₁} {pr₀} {pr₁} {u₀} {u₁} {eq₀} {eq₁} aᴹ tᴹ pᴹ prᴹ uᴹ eqᴹ =
  J (λ eq₁ eqᴹ → Id (pᴹ uᴹ eqᴹ (J p₀ pr₀ eq₀)) (J p₁ pr₁ eq₁))
     (J (λ u₁ uᴹ → Id (pᴹ uᴹ refl (J p₀ pr₀ eq₀))
                      (J p₁ pr₁ ((tᴹ ⁻¹) ◾ ap aᴹ eq₀ ◾ uᴹ)))
        (J (λ u₀ eq₀ → Id (pᴹ refl refl (J p₀ pr₀ eq₀))
                          (J p₁ pr₁ ((tᴹ ⁻¹) ◾ ap aᴹ eq₀ ◾ refl)))
           (J (λ t₁ tᴹ →
                 (p₁  : (x : a₁) → Id t₁ x → Set)
                 (pᴹ  : {x₀ : a₀} {x₁ : a₁} (xᴹ : Id (aᴹ x₀) x₁) {z₀ : Id t₀ x₀}
                       {z₁ : Id t₁ x₁} →
                       Id ((tᴹ ⁻¹) ◾ ap aᴹ z₀ ◾ xᴹ) z₁ → p₀ x₀ z₀ → p₁ x₁ z₁)
                 (pr₁ : p₁ t₁ refl)
                 (prᴹ : Id (pᴹ tᴹ (J (λ z p → Id ((p ⁻¹) ◾ p) refl) refl tᴹ) pr₀) pr₁)
                 →
                 Id (pᴹ refl refl pr₀) (J p₁ pr₁ ((tᴹ ⁻¹) ◾ refl)))
               (λ p₁ pᴹ pr₁ prᴹ → prᴹ)
               tᴹ p₁ pᴹ pr₁ prᴹ)
           eq₀)
        uᴹ)
     eqᴹ

Jβᴹ :
  {a₀  : U}                         {a₁  : U}
  {t₀  : a₀}                        {t₁  : a₁}
  {p₀  : (x : a₀)(z : t₀ ≡ x) → U}  {p₁  : (x : a₁)(z : t₁ ≡ x) → U}
  {pr₀ : p₀ t₀ refl}                {pr₁ : p₁ t₁ refl}

  (aᴹ : Uᴹ a₀ a₁)
  (tᴹ : Elᴹ aᴹ t₀ t₁)
  (pᴹ : ∀ {x₀ x₁}(xᴹ : Elᴹ aᴹ x₀ x₁){z₀ : t₀ ≡ x₀}{z₁ : t₁ ≡ x₁}(tᴹ : Elᴹ (≡ᴹ aᴹ tᴹ xᴹ) z₀ z₁)
        → Uᴹ (p₀ x₀ z₀) (p₁ x₁ z₁))
  (prᴹ : Elᴹ (pᴹ tᴹ (reflᴹ aᴹ tᴹ)) pr₀ pr₁)

  → Elᴹ (≡ᴹ (pᴹ tᴹ (reflᴹ aᴹ tᴹ)) (Jᴹ aᴹ tᴹ pᴹ prᴹ tᴹ (reflᴹ aᴹ tᴹ)) prᴹ) refl refl
Jβᴹ {a₀} {a₁} {t₀} {t₁} {p₀} {p₁} {pr₀} {pr₁} aᴹ tᴹ pᴹ prᴹ =
  J (λ pr₁ prᴹ → Elᴹ
                   (≡ᴹ (pᴹ tᴹ (reflᴹ aᴹ tᴹ)) (Jᴹ aᴹ tᴹ pᴹ prᴹ tᴹ (reflᴹ aᴹ tᴹ)) prᴹ)
                   refl refl)
     (J (λ t₁ tᴹ →
           (p₁  : (x : a₁) → t₁ ≡ x → U)
           (pᴹ  : {x₀ : a₀} {x₁ : a₁} (xᴹ : Elᴹ aᴹ x₀ x₁) {z₀ : t₀ ≡ x₀}
                  {z₁ : t₁ ≡ x₁} →
                  Elᴹ (≡ᴹ aᴹ tᴹ xᴹ) z₀ z₁ → Uᴹ (p₀ x₀ z₀) (p₁ x₁ z₁))
           →
           ≡ᴹ (pᴹ tᴹ (inv tᴹ))
              (Jᴹ aᴹ tᴹ pᴹ refl tᴹ (inv tᴹ)) refl refl
           ≡ refl)
        (λ p₁ pᴹ → refl)
        tᴹ p₁ pᴹ)
     prᴹ

-- Displayed algebra sections
--------------------------------------------------------------------------------

-- Universe

Setˢ : {A : Set}(Aᴰ : Setᴰ A) → Set₁
Setˢ {A} Aᴰ = (x : A) → Aᴰ x → Set

Uˢ : (A : Set) → Setᴰ A → Set
Uˢ a aᴰ = (x : a) → aᴰ x

Elˢ : (a : U)(aᴰ : Uᴰ a)(aˢ : Uˢ a aᴰ) → Setˢ ( aᴰ)
Elˢ a aᴰ aˢ x xₘ = aˢ x ≡ xₘ

-- Inductive functions
Πˢ : {a : U}      (aᴰ : Uᴰ a)                          (aˢ : Uˢ a aᴰ)
     {B : a → Set}(Bᴰ : ∀ {x}(xₘ :  aᴰ x) → Setᴰ (B x))(Bˢ : ∀ {x} xₘ (xₑ : Elˢ _ aᴰ aˢ x xₘ) → Setˢ (Bᴰ xₘ))
     → Setˢ (Πᴰ aᴰ Bᴰ)
Πˢ {a} aᴰ aˢ {B} Bᴰ Bˢ f fₘ = (x : a) → Bˢ {x} (aˢ x) (refl {x = aˢ x}) (f x) (fₘ x (aˢ x))

appˢ :
  {a : U}      (aᴰ : Uᴰ a)                          (aˢ : Uˢ a aᴰ)
  {B : a → Set}(Bᴰ : ∀ {x}(xₘ :  aᴰ x) → Setᴰ (B x))(Bˢ : ∀ {x} xₘ (xₑ : Elˢ _ aᴰ aˢ x xₘ) → Setˢ (Bᴰ xₘ))
  {t : Π a B}  (tᴰ : Πᴰ aᴰ Bᴰ t)                    (tˢ : Πˢ aᴰ aˢ Bᴰ Bˢ t tᴰ)
  {u : a}      (uᴰ :  aᴰ u)                         (uˢ : Elˢ _ aᴰ aˢ u uᴰ)
  → Bˢ uᴰ uˢ (t u) (tᴰ u uᴰ)
appˢ {a} aᴰ aˢ {B} Bᴰ Bˢ {t} tᴰ tˢ {u} uᴰ uˢ =
  (J (λ uᴰ uˢ → Bˢ {u} uᴰ uˢ (t u) (tᴰ u uᴰ)) (tˢ u)) {uᴰ} uˢ


-- non-inductive functions
Πₙᵢˢ :
  (A : Set)
  {B : A → Set}   (Bᴰ : ∀ a → Setᴰ (B a))   (Bˢ : ∀ a → Setˢ (Bᴰ a))
  → Setˢ (Πₙᵢᴰ A Bᴰ)
Πₙᵢˢ A {B} Bᴰ Bˢ f fᴰ = (a : A) → Bˢ a (f a) (fᴰ a)

appₙᵢˢ :
  ∀ (A : Set)
    {B : A → Set}  (Bᴰ : ∀ a → Setᴰ (B a)) (Bˢ : ∀ a → Setˢ (Bᴰ a))
    {t : Πₙᵢ A B}  (tᴰ : Πₙᵢᴰ A Bᴰ t)      (tˢ : Πₙᵢˢ A Bᴰ Bˢ t tᴰ)
    (a : A)
  → Bˢ a (t a) (tᴰ a)
appₙᵢˢ A {B} Bᴰ Bˢ {t} tᴰ tˢ a = tˢ a

-- Small non-inductive functions
Πₙᵢₛˢ :
  (A : Set)
  {b : A → U} (bᴰ : ∀ a → Uᴰ (b a)) (bˢ : ∀ a → Uˢ (b a) (bᴰ a))
  → Uˢ (Πₙᵢₛ A b) (Πₙᵢₛᴰ A bᴰ)
Πₙᵢₛˢ A {b} bᴰ bˢ = λ f a → bˢ a (f a)

appₙᵢₛˢ :
  (A : Set)
  {b : A → U}    (bᴰ : ∀ a → Uᴰ (b a)) (bˢ : ∀ a → Uˢ (b a) (bᴰ a))
  {t : Πₙᵢₛ A b} (tᴰ : Πₙᵢₛᴰ A bᴰ t)   (tˢ : Elˢ _ (Πₙᵢₛᴰ A bᴰ) (Πₙᵢₛˢ A bᴰ bˢ) t tᴰ)
  (a : A)
  → Elˢ _ (bᴰ a) (bˢ a) (t a) (tᴰ a)
appₙᵢₛˢ A {b} bᴰ bˢ {t} tᴰ tˢ a = ap (λ f → f a) {λ a → bˢ a (t a)}{tᴰ} tˢ

-- Small identity
≡ˢ :
  (a : U)(aᴰ : Uᴰ a)    (aˢ : Uˢ a aᴰ)
  (t : a)(tᴰ : Elᴰ aᴰ t)(tˢ : Elˢ _ aᴰ aˢ t tᴰ)
  (u : a)(uᴰ : Elᴰ aᴰ u)(uˢ : Elˢ _ aᴰ aˢ u uᴰ)
  → Uˢ (t ≡ u) (≡ᴰ aᴰ tᴰ uᴰ)
≡ˢ a aᴰ aˢ t tᴰ tˢ u uᴰ uˢ =
  λ e → tr (λ xᴰ → tr aᴰ e xᴰ ≡ uᴰ) tˢ (tr (λ yᴰ → tr aᴰ e (aˢ t) ≡ yᴰ) uˢ (apd aᴰ aˢ t u e))

reflˢ :
  {a : U} (aᴰ : Uᴰ a)    (aˢ : Uˢ a aᴰ)
  {t : a} (tᴰ : Elᴰ aᴰ t)(tˢ : Elˢ _ aᴰ aˢ t tᴰ)
  → Elˢ _ (≡ᴰ aᴰ tᴰ tᴰ) (≡ˢ a aᴰ aˢ t tᴰ tˢ t tᴰ tˢ) refl (reflᴰ aᴰ tᴰ)
reflˢ {a} aᴰ aˢ {t} tᴰ tˢ =
 J (λ xᴰ xˢ →
         tr (λ yᴰ → yᴰ ≡ xᴰ) xˢ (tr (λ yᴰ → aˢ t ≡ yᴰ) xˢ refl) ≡ refl)
       refl
       tˢ

-- Alternative, more structured implementation
-- ≡ˢ :
--   (a : U)(aᴰ : Uᴰ a)    (aˢ : Uˢ a aᴰ)
--   (t : a)(tᴰ : Elᴰ aᴰ t)(tˢ : Elˢ _ aᴰ aˢ t tᴰ)
--   (u : a)(uᴰ : Elᴰ aᴰ u)(uˢ : Elˢ _ aᴰ aˢ u uᴰ)
--   → Uˢ (t ≡ u) (≡ᴰ aᴰ tᴰ uᴰ)
-- ≡ˢ a aᴰ aˢ t tᴰ tˢ u uᴰ uˢ =
--   λ e → ap (tr aᴰ e) (tˢ ⁻¹) ◾ apd aᴰ aˢ t u e ◾ uˢ

-- reflˢ :
--   {a : U} (aᴰ : Uᴰ a)    (aˢ : Uˢ a aᴰ)
--   {t : a} (tᴰ : Elᴰ aᴰ t)(tˢ : Elˢ _ aᴰ aˢ t tᴰ)
--   → Elˢ _ (≡ᴰ aᴰ tᴰ tᴰ) (≡ˢ a aᴰ aˢ t tᴰ tˢ t tᴰ tˢ) refl (reflᴰ aᴰ tᴰ)
-- reflˢ {a} aᴰ aˢ {t} tᴰ tˢ =
--   ap (_◾ tˢ) (ap-id (tˢ ⁻¹)) ◾ inv tˢ


Jˢ :
  {a : U}(aᴰ  : Uᴰ a) (aˢ  : Uˢ a aᴰ)
  {t : a}(tᴰ  : aᴰ t) (tˢ  : Elˢ _ aᴰ aˢ t tᴰ)

  {p : (x : a)(z : t ≡ x) → U}
    (pᴰ : ∀ x (xᴰ : aᴰ x) z (zᴰ : (≡ᴰ aᴰ tᴰ xᴰ) z) → Uᴰ (p x z))
      (pˢ : ∀ x xᴰ (xˢ : Elˢ _ aᴰ aˢ x xᴰ) z zᴰ (zˢ : Elˢ _ (≡ᴰ aᴰ tᴰ xᴰ) (≡ˢ _ aᴰ aˢ _ tᴰ tˢ _ xᴰ xˢ) z zᴰ)
            → Uˢ (p x z) (pᴰ _ xᴰ _ zᴰ))

  {pr : p t refl}
    (prᴰ : pᴰ _ tᴰ _ (reflᴰ aᴰ tᴰ) pr)
      (prˢ : Elˢ _ (pᴰ _ tᴰ _ (reflᴰ aᴰ tᴰ)) (pˢ _ tᴰ tˢ _ (reflᴰ aᴰ tᴰ) (reflˢ aᴰ aˢ tᴰ tˢ)) pr prᴰ)

  {u : a}(uᴰ : aᴰ u)(uˢ : Elˢ _ aᴰ aˢ u uᴰ)

  {eq : t ≡ u}
    (eqᴰ : (≡ᴰ aᴰ tᴰ uᴰ) eq)
      (eqˢ : Elˢ _ (≡ᴰ aᴰ tᴰ uᴰ) (≡ˢ _ aᴰ aˢ _ tᴰ tˢ _ uᴰ uˢ) eq eqᴰ)

  → Elˢ _ (pᴰ _ uᴰ _ eqᴰ) (pˢ _ uᴰ uˢ _ eqᴰ eqˢ) (J p pr eq) (Jᴰ _ aᴰ _ tᴰ _ pᴰ _ prᴰ _ uᴰ _ eqᴰ)
Jˢ {a} aᴰ aˢ {t} tᴰ tˢ {p} pᴰ pˢ {pr} prᴰ prˢ {u} uᴰ uˢ {eq} eqᴰ eqˢ =
   J (λ eqᴰ eqˢ →
         Elˢ (p u eq) (pᴰ u uᴰ eq eqᴰ) (pˢ u uᴰ uˢ eq eqᴰ eqˢ)
         (J p pr eq) (Jᴰ a aᴰ t tᴰ p pᴰ pr prᴰ u uᴰ eq eqᴰ))
      (J (λ uᴰ uˢ → Elˢ (p u eq) (pᴰ u uᴰ eq (≡ˢ a aᴰ aˢ t tᴰ tˢ u uᴰ uˢ eq))
                    (pˢ u uᴰ uˢ eq (≡ˢ a aᴰ aˢ t tᴰ tˢ u uᴰ uˢ eq) refl) (J p pr eq)
                    (Jᴰ a aᴰ t tᴰ p pᴰ pr prᴰ u uᴰ eq (≡ˢ a aᴰ aˢ t tᴰ tˢ u uᴰ uˢ eq)))
         (J (λ u eq → Elˢ (p u eq)
              (pᴰ u (aˢ u) eq (≡ˢ a aᴰ aˢ t tᴰ tˢ u (aˢ u) refl eq))
              (pˢ u (aˢ u) refl eq (≡ˢ a aᴰ aˢ t tᴰ tˢ u (aˢ u) refl eq) refl)
              (J p pr eq)
              (Jᴰ a aᴰ t tᴰ p pᴰ pr prᴰ u (aˢ u) eq
               (≡ˢ a aᴰ aˢ t tᴰ tˢ u (aˢ u) refl eq)))
             (J (λ tᴰ tˢ →
                  (pᴰ : (x : a) (xᴰ : aᴰ x) (z : Id t x) → ≡ᴰ aᴰ tᴰ xᴰ z → Uᴰ (p x z))
                  (pˢ : (x : a) (xᴰ : aᴰ x) (xˢ : Elˢ a aᴰ aˢ x xᴰ) (z : Id t x)
                        (zᴰ : Id (tr aᴰ z tᴰ) xᴰ) →
                        Elˢ (t ≡ x) (≡ᴰ aᴰ tᴰ xᴰ) (≡ˢ a aᴰ aˢ t tᴰ tˢ x xᴰ xˢ) z zᴰ →
                        Uˢ (p x z) (pᴰ x xᴰ z zᴰ))
                  (prᴰ : pᴰ t tᴰ refl (reflᴰ aᴰ tᴰ) pr)
                  (prˢ : Elˢ (p t refl) (pᴰ t tᴰ refl (reflᴰ aᴰ tᴰ))
                        (pˢ t tᴰ tˢ refl (reflᴰ aᴰ tᴰ) (reflˢ aᴰ aˢ tᴰ tˢ)) pr prᴰ)
                  → Elˢ (p t refl)
                     (pᴰ t (aˢ t) refl (≡ˢ a aᴰ aˢ t tᴰ tˢ t (aˢ t) refl refl))
                     (pˢ t (aˢ t) refl refl (≡ˢ a aᴰ aˢ t tᴰ tˢ t (aˢ t) refl refl)
                     refl) pr
                     (Jᴰ a aᴰ t tᴰ p pᴰ pr prᴰ t (aˢ t) refl
                     (≡ˢ a aᴰ aˢ t tᴰ tˢ t (aˢ t) refl refl)))
                 (λ pᴰ pˢ prᴰ prˢ → prˢ)
                 tˢ pᴰ pˢ prᴰ prˢ)
             eq)
         uˢ)
      eqˢ

Jβˢ :
  {a : Set}(aᴰ  : Uᴰ a) (aˢ  : Uˢ a aᴰ)
  {t : a}  (tᴰ  : aᴰ t) (tˢ  : Elˢ _ aᴰ aˢ t tᴰ)

  {p : (x : a)(z : t ≡ x) → Set}
    (pᴰ : ∀ x (xᴰ : aᴰ x) z (zᴰ : (≡ᴰ aᴰ tᴰ xᴰ) z) → Uᴰ (p x z))
      (pˢ : ∀ x xᴰ (xˢ : Elˢ _ aᴰ aˢ x xᴰ) z zᴰ (zˢ : Elˢ _ (≡ᴰ aᴰ tᴰ xᴰ) (≡ˢ _ aᴰ aˢ _ tᴰ tˢ _ xᴰ xˢ) z zᴰ)
            → Uˢ (p x z) (pᴰ _ xᴰ _ zᴰ))

  {pr : p t refl}
    (prᴰ : pᴰ _ tᴰ _ (reflᴰ aᴰ tᴰ) pr)
      (prˢ : Elˢ _ (pᴰ _ tᴰ _ (reflᴰ aᴰ tᴰ)) (pˢ _ tᴰ tˢ _ (reflᴰ aᴰ tᴰ) (reflˢ aᴰ aˢ tᴰ tˢ)) pr prᴰ)

  → Elˢ (J p pr refl ≡ pr)
        (≡ᴰ (pᴰ t tᴰ refl refl) (Jᴰ a aᴰ t tᴰ p pᴰ pr prᴰ t tᴰ refl refl) prᴰ)
        (≡ˢ (p t refl) (pᴰ t tᴰ refl refl) (pˢ t tᴰ tˢ refl refl (reflˢ aᴰ aˢ tᴰ tˢ))
            (J p pr refl) (Jᴰ a aᴰ t tᴰ p pᴰ pr prᴰ t tᴰ refl refl)
                          (Jˢ {a} aᴰ aˢ {t} tᴰ tˢ {p} pᴰ pˢ {pr} prᴰ prˢ tᴰ tˢ refl (reflˢ aᴰ aˢ tᴰ tˢ)) pr prᴰ prˢ)
        refl
        (Jβᴰ aᴰ tᴰ pᴰ prᴰ)

Jβˢ {a} aᴰ aˢ {t} tᴰ tˢ {p} pᴰ pˢ {pr} prᴰ prˢ =
  J (λ prᴰ prˢ → Elˢ (pr ≡ pr)
         (≡ᴰ (pᴰ t tᴰ refl refl) (Jᴰ a aᴰ t tᴰ p pᴰ pr prᴰ t tᴰ refl refl)
          prᴰ)
         (≡ˢ (p t refl) (pᴰ t tᴰ refl refl)
          (pˢ t tᴰ tˢ refl refl (reflˢ aᴰ aˢ tᴰ tˢ)) pr
          (Jᴰ a aᴰ t tᴰ p pᴰ pr prᴰ t tᴰ refl refl)
          (Jˢ aᴰ aˢ tᴰ tˢ pᴰ pˢ prᴰ prˢ tᴰ tˢ (reflᴰ aᴰ tᴰ)
           (reflˢ aᴰ aˢ tᴰ tˢ))
          pr prᴰ prˢ)
         refl (Jβᴰ aᴰ tᴰ pᴰ prᴰ))
      (J (λ tᴰ tˢ →
               (pᴰ  : (x : a) (xᴰ : aᴰ x) (z : Id t x) → ≡ᴰ aᴰ tᴰ xᴰ z → Uᴰ (p x z))
             → (pˢ  : (x : a) (xᴰ : aᴰ x) (xˢ : Elˢ a aᴰ aˢ x xᴰ) (z : Id t x)
                  (zᴰ : Id (tr aᴰ z tᴰ) xᴰ) →
                  Elˢ (t ≡ x) (≡ᴰ aᴰ tᴰ xᴰ) (≡ˢ a aᴰ aˢ t tᴰ tˢ x xᴰ xˢ) z zᴰ →
                  Uˢ (p x z) (pᴰ x xᴰ z zᴰ))
             → Elˢ (pr ≡ pr)
             (≡ᴰ (pᴰ t tᴰ refl refl)
              (Jᴰ a aᴰ t tᴰ p pᴰ pr
               (pˢ t tᴰ tˢ refl (reflᴰ aᴰ tᴰ) (reflˢ aᴰ aˢ tᴰ tˢ) pr) t tᴰ refl
               refl)
              (pˢ t tᴰ tˢ refl (reflᴰ aᴰ tᴰ) (reflˢ aᴰ aˢ tᴰ tˢ) pr))
             (≡ˢ (p t refl) (pᴰ t tᴰ refl refl)
              (pˢ t tᴰ tˢ refl refl (reflˢ aᴰ aˢ tᴰ tˢ)) pr
              (Jᴰ a aᴰ t tᴰ p pᴰ pr
               (pˢ t tᴰ tˢ refl (reflᴰ aᴰ tᴰ) (reflˢ aᴰ aˢ tᴰ tˢ) pr) t tᴰ refl
               refl)
              (Jˢ aᴰ aˢ tᴰ tˢ pᴰ pˢ
               (pˢ t tᴰ tˢ refl (reflᴰ aᴰ tᴰ) (reflˢ aᴰ aˢ tᴰ tˢ) pr) refl tᴰ tˢ
               (reflᴰ aᴰ tᴰ) (reflˢ aᴰ aˢ tᴰ tˢ))
              pr (pˢ t tᴰ tˢ refl (reflᴰ aᴰ tᴰ) (reflˢ aᴰ aˢ tᴰ tˢ) pr) refl)
             refl
             (Jβᴰ aᴰ tᴰ pᴰ
              (pˢ t tᴰ tˢ refl (reflᴰ aᴰ tᴰ) (reflˢ aᴰ aˢ tᴰ tˢ) pr)))
          (λ pᴰ pˢ → refl)
          tˢ pᴰ pˢ)
      prˢ