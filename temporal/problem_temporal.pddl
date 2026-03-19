(define (problem deliver-packages-temporal)

    ;;=========================================================================
    ;; Use the "package-delivery-temporal" domain which defines actions for moving vans/drivers,
    ;; loading/unloading packages, and other logistics operations.
    ;;=========================================================================

    (:domain package-delivery-temporal)

    ;;=========================================================================
    ;; Declare objects used in this problem
    ;;=========================================================================
    (:objects
        amritsar jandiala rayya mehta - location
        van1 van2 - van
        driver1 driver2 - driver
        pkg1 pkg2 pkg3 pkg4 - package
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
        (driver-at-location driver1 amritsar)
        (driver-at-location driver2 rayya)

        ;; Both drivers are initially available for tasks
        (is-driver-available driver1)
        (is-driver-available driver2)

        ;; Driver1 can walk between connected locations initially
        (driver-can-walk driver1)

        ;; Initial locations of vans
        (van-at-location van1 jandiala)
        (van-at-location van2 rayya)

        ;; Both vans are initially available for delivery tasks
        (is-van-available van1)
        (is-van-available van2)

        ;; Both vans are initially empty and ready for loading packages
        (is-van-empty van1)
        (is-van-empty van2)

        ;; Initial locations of packages
        (package-at-location pkg1 jandiala)
        (package-at-location pkg2 rayya)

        ;; Packages (1 and 2) are ready for pickup at their respective initial locations
        (is-package-ready pkg1)
        (is-package-ready pkg2)

        ;; Fuel stations
        (fuel-station amritsar)
        (fuel-station rayya)

        ;; Fuel levels
        (= (van-fuel-level van1) 30) ;;fuel kept greather than required for full trip so that refuelling action is not needed
        (= (van-fuel-level van2) 20) ;; fuel kept less than required for full trip so that refuelling action can be tested

        ;; Both van's fuel onsumption rates
        (= (van-fuel-consumption-rate van1) 1.0)
        (= (van-fuel-consumption-rate van2) 1.5)

        ;; Distances (in units) between connected locations
        (= (location-distance amritsar jandiala) 10)
        (= (location-distance jandiala amritsar) 10)
        (= (location-distance jandiala rayya) 15)
        (= (location-distance rayya jandiala) 15)
        (= (location-distance rayya mehta) 12)
        (= (location-distance mehta rayya) 12)
        (= (location-distance mehta amritsar) 25)
        (= (location-distance amritsar mehta) 25)
    )

    (:goal
        (and
            (package-at-destination pkg1 amritsar);; package1 should be delivered to Amritsar (from Jandiala)
            (van-at-location van1 jandiala);; van1 should be parked back at Jandiala 
            (driver-at-location driver1 amritsar);; driver1 should be back at Amritsar location after delivery
            (package-at-destination pkg2 mehta) ;; package2 should be delivered to Mehta (from Rayya)
            (van-at-location van2 rayya);;van2 should be parked back at Rayya
            (driver-at-location driver2 rayya);; driver2 should be back at Rayya location after delivery
        )
    )

    (:constraints
        (and
            (within 20
                (package-at-destination pkg1 amritsar)) ;; package1 to be delivered within 20 time units
            (within 16
                (package-at-destination pkg2 mehta)) ;; package2 to be delivered within 16 time units
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