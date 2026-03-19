;;==========================================================
;; PACKAGE DELIVERY CLASSICAL DOMAIN
;;==========================================================
;; This file models a classical package-delivery-workflow 
;; encompassing driver mobility, van movement, 
;; and package handling across multiple connected locations.
;;==========================================================

(define (domain package-delivery)
  (:requirements :typing :strips :negative-preconditions)

  ;; ============================================================================
  ;; TYPES SECTION
  ;; ============================================================================
  (:types
    ;; Define object types used in the domain
    package van location driver - object
  )

  ;; ============================================================================
  ;; PREDICATEs SECTION
  ;; ============================================================================
  (:predicates
    ;; PACKAGE PREDICATES
    (package-in-van ?p - package ?v - van);; Package is currently in van
    (package-at-location ?p - package ?l - location);; Package's current location
    (package-at-destination ?p - package ?l - location);; Package reached its destination
    (is-package-ready ?p - package);; Package is ready for pickup
    (is-package-delivered ?p - package);; Package has been delivered

    ;; VAN PREDICATES
    (van-at-location ?v - van ?l - location);; Van's current location
    (is-van-available ?v - van);; Van is available for delivery
    (is-van-empty ?v - van);; Van got no packages and is ready for loading

    ;; DRIVER PREDICATES
    (driver-in-van ?d - driver ?v - van);; Driver is inside van
    (driver-at-location ?d - driver ?l - location);; Driver's current location
    (is-driver-available ?d - driver);; Driver is available to work
    (is-driver-tasked ?d - driver ?v - van);; Driver is assigned to a delivery task
    (is-driver-unboarded-van ?d - driver ?v - van);; Driver exited van at a location
    (driver-can-walk ?d - driver);; Driver can walk to locations ;(not driving)

    ;; CONNECTION PREDICATES
    (connects ?l1 ?l2 - location);; Two domian locations are connected
  )

  ;;======================================================================================
  ;; ACTION: WALK-DRIVER - Walk an available driver from one connected location to another
  ;;======================================================================================

  (:action walk-driver
    :parameters (?d - driver ?from ?to - location)
    :precondition (and
      (is-driver-available ?d) ;; Driver must be available to work
      (driver-can-walk ?d) ;; Driver must be available to walk ;(not driving)
      (connects ?from ?to) ;; Locations must be connected
      (driver-at-location ?d ?from) ;; Driver must be at origin
    )
    :effect (and
      (driver-at-location ?d ?to) ;; Driver moves to destination
      (not (driver-at-location ?d ?from)) ;; Driver leaves origin
    )
  )

  ;;=========================================================================
  ;; ACTION: DRIVER-BOARD-VAN -Driver enters a van at a location
  ;;=========================================================================

  (:action driver-board-van
    :parameters (?d - driver ?v - van ?l - location)
    :precondition (and
      (is-driver-available ?d) ;; Driver must be available to work
      (is-van-available ?v) ;; Van must be available for delivery
      (driver-at-location ?d ?l) ;; Driver at same location as van
      (van-at-location ?v ?l) ;; Van at same location as driver
    )
    :effect (and
      (driver-in-van ?d ?v) ;; Driver now in van
      (not (is-driver-unboarded-van ?d ?v)) ;; Driver is not unboarded now
    )
  )

  ;;=========================================================================
  ;; ACTION: DRIVER-UNBOARD-VAN - Driver exits the van at a location
  ;;=========================================================================

  (:action driver-unboard-van
    :parameters (?d - driver ?v - van ?l - location)
    :precondition (and
      (driver-in-van ?d ?v) ;; Driver must be in van
      (van-at-location ?v ?l) ;; Van at unboarding location
    )
    :effect (and
      (driver-at-location ?d ?l) ;; Driver now at location
      (not (driver-in-van ?d ?v)) ;; Driver leaves van now
      (is-driver-unboarded-van ?d ?v) ;; Mark this driver as unboarded
    )
  )

  ;;=========================================================================
  ;; ACTION: DRIVE-VAN - Driver drives van from one connected location to another
  ;;=========================================================================

  (:action drive-van
    :parameters (?d - driver ?v - van ?from ?to - location)
    :precondition (and
      (connects ?from ?to) ;; Origin and destination locations must be connected
      (driver-at-location ?d ?from) ;; Driver must be at starting location
      (van-at-location ?v ?from) ;; Van must be at starting location
      (driver-in-van ?d ?v) ;; Driver must be in van
    )
    :effect (and
      (van-at-location ?v ?to) ;; Van moves to destination location
      (not (van-at-location ?v ?from)) ;; Van leaves origin location
      (not (driver-at-location ?d ?from)) ;; Driver leaves origin location
    )
  )

  ;;====================================================================================
  ;; ACTION: LOAD-PACKAGE -Driver loads a ready package into an empty van at a location
  ;;====================================================================================

  (:action load-package
    :parameters (?d - driver ?p - package ?v - van ?l - location)
    :precondition (and
      (is-package-ready ?p) ;; Package must be ready to be loaded
      (is-driver-available ?d) ;; Driver must be available to work
      (is-van-available ?v) ;; Van must be available for delivery
      (is-van-empty ?v) ;; Van must be empty to load package
      (driver-at-location ?d ?l) ;; Driver at loading location
      (package-at-location ?p ?l) ;; Package at loading location
      (van-at-location ?v ?l) ;; Van at loading location
    )
    :effect (and
      (package-in-van ?p ?v) ;; Delivery package now in van
      (is-driver-tasked ?d ?v) ;; Driver assigned to delivery task
      (not (is-van-empty ?v)) ;; Van is now occupied
      (not (driver-can-walk ?d)) ;; Driver cannot walk once assigned to delivery
      (not (package-at-location ?p ?l)) ;; Package virtually leaves loading location as it's in van
    )
  )

  ;;===============================================================================
  ;; ACTION: UNLOAD-PACKAGE - Driver unloads package from van at delivery location
  ;;===============================================================================

  (:action unload-package
    :parameters (?d - driver ?p - package ?v - van ?l - location)
    :precondition (and
      (driver-at-location ?d ?l) ;; Driver at unloading location
      (van-at-location ?v ?l) ;; Van at unloading location
      (package-in-van ?p ?v) ;; Van must have a package to unload
      (is-driver-tasked ?d ?v) ;; Unloading driver is on delivery task
      (is-driver-unboarded-van ?d ?v) ;; Unloading driver has exited van at this location
    )
    :effect (and
      (package-at-location ?p ?l) ;; Package now at this location
      (is-package-delivered ?p) ;; Package marked as delivered
      (package-at-destination ?p ?l) ;; Package reached its destination
      (is-van-empty ?v) ;; Van becomes empty
      (driver-can-walk ?d) ;; Driver can walk again
      (not(is-driver-tasked ?d ?v)) ;; Driver task completed and is free now
      (not(is-package-ready ?p)) ;; Package is delivered so no longer ready for pickup
      (not (package-in-van ?p ?v)) ;; Package out of van and van is empty now
    )
  )
)

;;====================================================================================================

;;Tool Used: Microsoft Copilot

;;Purpose: To refine comments, making them more concise and meaningful

;;Reflection: 
;;Using Copilot helped me transforming lengthy comments into crisp, well-structured statements, 
;;and improved overall code readability.

;;====================================================================================================