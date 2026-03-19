(define (problem deliver-packages)

  ;;=========================================================================
  ;; Use the "package-delivery" domain which defines actions for moving vans/drivers,
  ;; loading/unloading packages, and other logistics operations.
  ;;=========================================================================

  (:domain package-delivery)

  ;;=========================================================================
  ;; Declare objects used in this problem
  ;;=========================================================================
  (:objects
    amritsar jandiala rayya mehta - location ;; places where vans, drivers and packages can be
    van1 van2 - van ;; vehicles to move packages between connected locations
    driver1 driver2 - driver ;; delivery staff who can drive vans or walk between connected locations
    pkg1 pkg2 pkg3 pkg4 - package ;; items to be delivered
    )

  ;;=========================================================================
  ;; Define initial state of the problem
  ;;=========================================================================

  (:init
    ;; Establish connectivity between delivery locations (bidirectional in this problem)
    ;; Define which adjacent locations can be commuted by drivers/vans.
    ;; e.g., amritsar <-> jandiala means a driver/van can move between these two locations
    ;; similarly for other location pairs.
    (connects amritsar jandiala) ;; Amritsar <-> Jandiala
    (connects jandiala amritsar)
    (connects jandiala rayya) ;; Jandiala <-> Rayya
    (connects rayya jandiala)
    (connects rayya mehta) ;; Rayya <-> Mehta
    (connects mehta rayya)
    (connects mehta amritsar) ;; Mehta <-> Amritsar
    (connects amritsar mehta)

    ;; Initial locations of drivers
    (driver-at-location driver1 amritsar) ;; driver1 begins at Amritsar location
    (driver-at-location driver2 rayya) ;; driver2 begins at Rayya location

    ;; Initial locations of vans
    (van-at-location van1 jandiala) ;; van1 begins at Jandiala location
    (van-at-location van2 rayya) ;; van2 begins at Rayya location

    ;; Initial locations of packages
    (package-at-location pkg1 jandiala) ; package number 1 is at Jandiala location
    (package-at-location pkg2 rayya) ; package number 2 is at Rayya location

    ;; Both vans are initially available for delivery tasks
    (is-van-available van1)
    (is-van-available van2)

    ;; Both drivers are initially available for tasks
    (is-driver-available driver1)
    (is-driver-available driver2)

    ;; Both vans are initially empty and ready for loading packages
    (is-van-empty van1)
    (is-van-empty van2)

    ;; Driver1 can walk between connected locations initially
    (driver-can-walk driver1)

    ;; Packages (1 and 2) are ready for pickup at their respective initial locations
    (is-package-ready pkg1)
    (is-package-ready pkg2)

  )

  ;;=========================================================================
  ;; Define goal state of the problem
  ;;=========================================================================

  (:goal
    (and
      (package-at-destination pkg1 amritsar) ;; package1 should be delivered to Amritsar
      (van-at-location van1 jandiala) ;; van1 should be parked back at Jandiala 
      (driver-at-location driver1 amritsar) ;; driver1 should be back at Amritsar location after delivery
      (package-at-destination pkg2 mehta) ;; package2 should be delivered to Mehta
      (van-at-location van2 rayya) ;; van2 should be parked back at Rayya
      (driver-at-location driver2 rayya) ;; driver2 should be back at Rayya location after delivery
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