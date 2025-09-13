
(define-non-fungible-token child-sponsorship uint)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_OWNER (err u100))
(define-constant ERR_NOT_AUTHORIZED (err u101))
(define-constant ERR_NFT_NOT_FOUND (err u102))
(define-constant ERR_ALREADY_SPONSORED (err u103))
(define-constant ERR_INSUFFICIENT_PAYMENT (err u104))
(define-constant ERR_INVALID_CHILD_ID (err u105))
(define-constant ERR_UPDATE_NOT_FOUND (err u106))
(define-constant ERR_SUBSCRIPTION_ENDED (err u107))

(define-data-var next-child-id uint u1)
(define-data-var monthly-sponsorship-amount uint u1000000)

(define-map child-profiles
  uint
  {
    name: (string-ascii 50),
    age: uint,
    location: (string-ascii 100),
    needs: (string-ascii 200),
    ngo-address: principal,
    is-active: bool,
    created-at: uint
  }
)

(define-map sponsorships
  uint
  {
    sponsor: principal,
    start-block: uint,
    last-payment-block: uint,
    total-contributed: uint,
    is-active: bool
  }
)

(define-map progress-updates
  { child-id: uint, update-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    category: (string-ascii 20),
    updated-by: principal,
    timestamp: uint,
    verification-hash: (buff 32)
  }
)

(define-map update-counters uint uint)

(define-map authorized-ngos principal bool)

(define-map sponsor-children principal (list 50 uint))

(define-public (register-ngo (ngo principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_OWNER)
    (map-set authorized-ngos ngo true)
    (ok true)
  )
)

(define-public (create-child-profile
  (name (string-ascii 50))
  (age uint)
  (location (string-ascii 100))
  (needs (string-ascii 200))
)
  (let (
    (child-id (var-get next-child-id))
    (ngo-address tx-sender)
  )
    (asserts! (default-to false (map-get? authorized-ngos ngo-address)) ERR_NOT_AUTHORIZED)
    (try! (nft-mint? child-sponsorship child-id ngo-address))
    (map-set child-profiles child-id {
      name: name,
      age: age,
      location: location,
      needs: needs,
      ngo-address: ngo-address,
      is-active: true,
      created-at: stacks-block-height
    })
    (map-set update-counters child-id u0)
    (var-set next-child-id (+ child-id u1))
    (ok child-id)
  )
)

(define-public (sponsor-child (child-id uint))
  (let (
    (child-profile (unwrap! (map-get? child-profiles child-id) ERR_INVALID_CHILD_ID))
    (sponsorship-amount (var-get monthly-sponsorship-amount))
    (existing-sponsorship (map-get? sponsorships child-id))
  )
    (asserts! (get is-active child-profile) ERR_INVALID_CHILD_ID)
    (asserts! (is-none existing-sponsorship) ERR_ALREADY_SPONSORED)
    (try! (stx-transfer? sponsorship-amount tx-sender (get ngo-address child-profile)))
    (try! (nft-transfer? child-sponsorship child-id (get ngo-address child-profile) tx-sender))
    (map-set sponsorships child-id {
      sponsor: tx-sender,
      start-block: stacks-block-height,
      last-payment-block: stacks-block-height,
      total-contributed: sponsorship-amount,
      is-active: true
    })
    (let (
      (current-children (default-to (list) (map-get? sponsor-children tx-sender)))
    )
      (map-set sponsor-children tx-sender (unwrap! (as-max-len? (append current-children child-id) u50) ERR_INVALID_CHILD_ID))
    )
    (ok true)
  )
)

(define-public (make-monthly-payment (child-id uint))
  (let (
    (sponsorship (unwrap! (map-get? sponsorships child-id) ERR_NFT_NOT_FOUND))
    (child-profile (unwrap! (map-get? child-profiles child-id) ERR_INVALID_CHILD_ID))
    (payment-amount (var-get monthly-sponsorship-amount))
  )
    (asserts! (is-eq tx-sender (get sponsor sponsorship)) ERR_NOT_AUTHORIZED)
    (asserts! (get is-active sponsorship) ERR_SUBSCRIPTION_ENDED)
    (try! (stx-transfer? payment-amount tx-sender (get ngo-address child-profile)))
    (map-set sponsorships child-id
      (merge sponsorship {
        last-payment-block: stacks-block-height,
        total-contributed: (+ (get total-contributed sponsorship) payment-amount)
      })
    )
    (ok true)
  )
)

(define-public (add-progress-update
  (child-id uint)
  (title (string-ascii 100))
  (description (string-ascii 500))
  (category (string-ascii 20))
  (verification-hash (buff 32))
)
  (let (
    (child-profile (unwrap! (map-get? child-profiles child-id) ERR_INVALID_CHILD_ID))
    (current-updates (default-to u0 (map-get? update-counters child-id)))
    (new-update-id (+ current-updates u1))
  )
    (asserts! (is-eq tx-sender (get ngo-address child-profile)) ERR_NOT_AUTHORIZED)
    (map-set progress-updates { child-id: child-id, update-id: new-update-id } {
      title: title,
      description: description,
      category: category,
      updated-by: tx-sender,
      timestamp: stacks-block-height,
      verification-hash: verification-hash
    })
    (map-set update-counters child-id new-update-id)
    (ok new-update-id)
  )
)

(define-public (end-sponsorship (child-id uint))
  (let (
    (sponsorship (unwrap! (map-get? sponsorships child-id) ERR_NFT_NOT_FOUND))
  )
    (asserts! (is-eq tx-sender (get sponsor sponsorship)) ERR_NOT_AUTHORIZED)
    (map-set sponsorships child-id (merge sponsorship { is-active: false }))
    (ok true)
  )
)

(define-public (set-monthly-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_OWNER)
    (var-set monthly-sponsorship-amount new-amount)
    (ok true)
  )
)

(define-read-only (get-child-profile (child-id uint))
  (map-get? child-profiles child-id)
)

(define-read-only (get-sponsorship-info (child-id uint))
  (map-get? sponsorships child-id)
)

(define-read-only (get-progress-update (child-id uint) (update-id uint))
  (map-get? progress-updates { child-id: child-id, update-id: update-id })
)

(define-read-only (get-update-count (child-id uint))
  (default-to u0 (map-get? update-counters child-id))
)

(define-read-only (get-monthly-amount)
  (var-get monthly-sponsorship-amount)
)

(define-read-only (get-sponsor-children (sponsor principal))
  (default-to (list) (map-get? sponsor-children sponsor))
)

(define-read-only (is-ngo-authorized (ngo principal))
  (default-to false (map-get? authorized-ngos ngo))
)

(define-read-only (get-nft-owner (child-id uint))
  (nft-get-owner? child-sponsorship child-id)
)

(define-read-only (calculate-payment-due (child-id uint))
  (match (map-get? sponsorships child-id)
    sponsorship
    (let (
      (blocks-since-payment (- stacks-block-height (get last-payment-block sponsorship)))
      (monthly-blocks u4320)
    )
      (if (>= blocks-since-payment monthly-blocks)
        (some (var-get monthly-sponsorship-amount))
        none
      )
    )
    none
  )
)

(define-read-only (get-total-children)
  (- (var-get next-child-id) u1)
)

