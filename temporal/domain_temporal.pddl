;;==========================================================
;; PACKAGE DELIVERY TEMPORAL DOMAIN
;;==========================================================
;; This file models a temporal package-delivery-workflow 
;; encompassing driver mobility, van movement, 
;; and package handling across multiple connected locations.
;;==========================================================

(define (domain package-delivery-temporal)
    (:requirements :typing :durative-actions :numeric-fluents)

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
        (is-driver-unboarded-van ?d - driver ?v - van);; Driver exited van (not in van)
        (driver-can-walk ?d - driver);; Driver can walk to locations ;(not driving)

        ;; CONNECTION PREDICATES
        (connects ?l1 ?l2 - location);; Two domian locations are connected

        ;; FUEL-STATION PREDICATES
        (fuel-station ?l - location)
    )

    ;; ============================================================================
    ;; FUNCTIONS SECTION
    ;; ============================================================================

    (:functions
        ;; FUEL-RELATED FUNCTIONS        
        (van-fuel-level ?v - van) ;;Represents the current units of fuel in a van to ensure sufficient fuel for delivery.
        (van-fuel-consumption-rate ?v - van);; Defines how much fuel a specific van consumes per unit distance travelled

        ;; DISTANCE FUNCTION
        (location-distance ?from ?to - location) ;;Represents the distance between two locations
    )

    ;;===============================================================================================
    ;; DURATIVE ACTION: WALK-DRIVER - Walk an available driver from one connected location to another
    ;;===============================================================================================

    (:durative-action walk-driver
        :parameters (?d - driver ?from ?to - location)
        :duration (= ?duration (* 1.0 (location-distance ?from ?to))) ;; Walking speed assumed as 1 distance unit per time unit
        :condition (and
            (at start (is-driver-available ?d))
            (over all (driver-can-walk ?d))
            (over all (connects ?from ?to))
            (at start (driver-at-location ?d ?from))
        )
        :effect (and
            (at end (driver-at-location ?d ?to))
            (at start (not (driver-at-location ?d ?from)))
        )
    )

    ;;=========================================================================
    ;; DURATIVE ACTION: DRIVER-BOARD-VAN -Driver enters a van at a location
    ;;=========================================================================
    (:durative-action driver-board-van
        :parameters (?d - driver ?v - van ?l - location)
        :duration (= ?duration 1)
        :condition (and
            (at start (is-driver-available ?d))
            (at start (is-van-available ?v))
            (over all (driver-at-location ?d ?l))
            (at start (van-at-location ?v ?l))
        )
        :effect (and
            (at end (driver-in-van ?d ?v))
            (at start (not (is-driver-unboarded-van ?d ?v)))
        )
    )

    ;;=========================================================================
    ;; DURATIVE ACTION: DRIVER-UNBOARD-VAN - Driver exits the van at a location
    ;;=========================================================================
    (:durative-action driver-unboard-van
        :parameters (?d - driver ?v - van ?l - location)
        :duration (= ?duration 1)
        :condition (and
            (at start (driver-in-van ?d ?v))
            (at start (van-at-location ?v ?l))
        )
        :effect (and
            (at end (driver-at-location ?d ?l))
            (at start (is-driver-unboarded-van ?d ?v))
            (at start (not (driver-in-van ?d ?v)))
        )
    )

    ;;=======================================================================================
    ;; DURATIVE ACTION: DRIVE-VAN - Driver drives van from one connected location to another
    ;;=======================================================================================
    (:durative-action drive-van
        :parameters (?d - driver ?v - van ?from ?to - location)
        :duration (= ?duration (* 0.5 (location-distance ?from ?to))) ;; Driving speed assumed as 2 distance units per time unit
        :condition (and
            (over all (connects ?from ?to))
            (at start (driver-at-location ?d ?from))
            (at start (van-at-location ?v ?from))
            (over all (driver-in-van ?d ?v))
            (at start (>= (van-fuel-level ?v) (*2 (* (van-fuel-consumption-rate ?v) (location-distance ?from ?to)))))
            ;; Ensure van has enough fuel for the trip
        )
        :effect (and
            (at start (not (van-at-location ?v ?from)))
            (at start (not (driver-at-location ?d ?from)))
            (at end (van-at-location ?v ?to))
            (at end (decrease
                    (van-fuel-level ?v)
                    (* (van-fuel-consumption-rate ?v) (location-distance ?from ?to))))
            ;; Decrease fuel level based on distance travelled and consumption rate
        )
    )

    ;;============================================================================================
    ;; DURATIVE ACTION: LOAD-PACKAGE -Driver loads a ready package into an empty van at a location
    ;;============================================================================================
    (:durative-action load-package
        :parameters (?d - driver ?p - package ?v - van ?l - location)
        :duration (= ?duration 1) ;; Loading takes 1 time unit
        :condition (and
            (at start (is-package-ready ?p))
            (at start (is-driver-available ?d))
            (at start (is-van-available ?v))
            (at start (is-van-empty ?v))
            (at start (driver-at-location ?d ?l))
            (at start (package-at-location ?p ?l))
            (at start (van-at-location ?v ?l))
        )
        :effect (and
            (at end (package-in-van ?p ?v))
            (at start (is-driver-tasked ?d ?v))
            (at end (not (is-van-empty ?v)))
            (at start (not (driver-can-walk ?d)))
            (at end (not (package-at-location ?p ?l)))
        )
    )

    ;;=======================================================================================
    ;; DURATIVE ACTION: UNLOAD-PACKAGE - Driver unloads package from van at delivery location
    ;;=======================================================================================
    (:durative-action unload-package
        :parameters (?d - driver ?p - package ?v - van ?l - location)
        :duration (= ?duration 2) ;; Unloading takes 2 time units
        :condition (and
            (over all (driver-at-location ?d ?l))
            (over all (van-at-location ?v ?l))
            (at start (package-in-van ?p ?v))
            (at start (is-driver-tasked ?d ?v))
            (over all (is-driver-unboarded-van ?d ?v))
        )
        :effect (and
            (at end (package-at-location ?p ?l))
            (at end (is-package-delivered ?p))
            (at end (package-at-destination ?p ?l))
            (at end (is-van-empty ?v))
            (at end (driver-can-walk ?d))
            (at end (not (is-driver-tasked ?d ?v)))
            (at end (not (is-package-ready ?p)))
            (at end (not (package-in-van ?p ?v)))
        )
    )

    ;;===============================================================================
    ;; DURATIVE ACTION: REFUEL-VAN - Driver refuels van at a fuel station location
    ;;===============================================================================
    (:durative-action refuel-van
        :parameters (?d - driver ?v - van ?l - location)
        :duration (= ?duration 3) ;; Refuelling takes 3 time units
        :condition (and
            (over all (driver-at-location ?d ?l))
            (over all (van-at-location ?v ?l))
            (over all (fuel-station ?l))
            (over all (is-van-available ?v))
            (over all (is-driver-available ?d))
            (over all (driver-in-van ?d ?v))
        )
        :effect (and
            (at end (increase (van-fuel-level ?v) 50))
            (at end (driver-in-van ?d ?v))
            (at start (not (driver-can-walk ?d)))
        )
    )
)
;;=========================================================================

;;Tool Used: Microsoft Copilot

;;Purpose: To refine comments, making them more concise and meaningful

;;Reflection: 
;;Using Copilot helped me transforming lengthy comments into crisp, well-structured statements, 
;;and improved overall code readability.

;;=========================================================================