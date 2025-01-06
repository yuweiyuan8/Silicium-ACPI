// This file contains common Power Management IC (PMIC) ACPI device definitions

//
//PMIC KMDF
//

Device (PMIC)
{
    Name (_DEP, Package (1)  // _DEP: Dependencies
    {
        \_SB.SPMI
    })
    Name (_HID, "QCOM6063")  // _HID: Hardware ID
    Name (_CID, "PNP0CA3")
    Alias (\_SB.PSUB, _SUB)
    Method (_STA, 0, NotSerialized)  // _STA: Status
    {
        Return (0x0F)
    }

    Method (PMCF)
    {
        Name (CFG0, Package ()
        {
            0x02, 
            Package ()
            {
                0x00, 
                0x01
            }, 
            Package ()
            {
                0x04, 
                0x05
            }
        })
        Return (CFG0) /* \_SB_.PMIC.PMCF.CFG0 */
    }
}

//
//PMIC
//
Device (PM01)
{
    Name (_HID, "QCOM6066")  // _HID: Hardware ID
    Name (_UID, 1)  // _UID: Unique ID
    Name (_DEP, Package (1)  // _DEP: Dependencies
    {
        \_SB.PMIC
    })
    Method (_STA, 0, NotSerialized)  // _STA: Status
    {
        Return (0x0F)
    }

    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
    {
        Name (RBUF, ResourceTemplate ()
        {
            Interrupt (ResourceConsumer, Level, ActiveHigh, Shared, ,, )
            {
                0x00000166,
            }
        })
        Return (RBUF) /* \_SB_.PM01._CRS.RBUF */
    }

    Method (PMIO, 0, NotSerialized)
    {
        Name (CFG0, Package (0x0B)
        {
            0, 
            0, 
            0x1040, 
            0x40, 
            0x1A, 
            0xC0, 
            0, 
            0xA0, 
            0, 
            0, 
            0
        })
        Return (CFG0) 
    }

    // _DSM method to mark PM01's ActiveBoth interrupts
    Method(_DSM, 0x4, NotSerialized) {
        // DSM UUID
        switch(ToBuffer(Arg0))
        {
            // ACPI DSM UUID for GPIO
            case(ToUUID("4F248F40-D5E2-499F-834C-27758EA1CD3F"))
            {
                // DSM Function
                switch(ToInteger(Arg2))
                {
                    // Function 0: Return supported functions, based on revision
                    case(0)
                    {
                        // revision 0: function 0 & 1 are supported.
                        return (Buffer() {0x3})
                    }

                    // Function 1: For emulated ActiveBoth controllers, returns
                    //             a package of controller-relative pin numbers.
                    //             Each corresponding pin will have an initial
                    //             polarity of ActiveHigh.
                    case(1)
                    {
                        // Marks pins to be ActiveHigh.
                        Return (Package() {0x40, 0x41})
                    }

                    default
                    {
                        // Functions 2+: not supported
                    }
                }
            }

            default
            {
                // No other GUIDs supported
                Return(Buffer(1) { 0x00 })
            }
        }
    }
}