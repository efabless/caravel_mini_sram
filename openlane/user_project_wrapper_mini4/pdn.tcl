# Copyright 2020-2022 Efabless Corporation
# Licensed under the Apache License, Version 2.0 (the "License");

source $::env(SCRIPTS_DIR)/openroad/common/set_global_connections.tcl
set_global_connections

# Set up primary and secondary power and ground nets
set secondary []
foreach vdd $::env(VDD_NETS) gnd $::env(GND_NETS) {
    if { $vdd != $::env(VDD_NET) } {
        lappend secondary $vdd
        set db_net [[ord::get_db_block] findNet $vdd]
        if {$db_net == "NULL"} {
            set net [odb::dbNet_create [ord::get_db_block] $vdd]
            $net setSpecial
            $net setSigType "POWER"
        }
    }
    if { $gnd != $::env(GND_NET) } {
        lappend secondary $gnd
        set db_net [[ord::get_db_block] findNet $gnd]
        if {$db_net == "NULL"} {
            set net [odb::dbNet_create [ord::get_db_block] $gnd]
            $net setSpecial
            $net setSigType "GROUND"
        }
    }
}

set_voltage_domain -name CORE -power $::env(VDD_NET) -ground $::env(GND_NET) \
    -secondary_power $secondary

# Define stdcell PDN grid with only metal 4 vertical
define_pdn_grid \
    -name stdcell_grid \
    -starts_with POWER \
    -voltage_domain CORE \
    -pins "met4"

# Add metal 4 vertical stripes
add_pdn_stripe \
    -grid stdcell_grid \
    -layer met4 \
    -width 3.1 \
    -pitch 60 \
    -offset 5 \
    -spacing 26.9 \
    -starts_with POWER -extend_to_core_ring

# Connect metal 4 to standard cells
add_pdn_connect \
    -grid stdcell_grid \
    -layers "met3 met4"

# Define macro PDN grid with metal 3 horizontal (already present in macro)
define_pdn_grid \
    -macro \
    -default \
    -name macro \
    -starts_with POWER \
    -halo "$::env(FP_PDN_HORIZONTAL_HALO) $::env(FP_PDN_VERTICAL_HALO)"

# Add a connection between macro (metal 3) and stdcell (metal 4)
add_pdn_connect \
    -grid stdcell_grid \
    -grid macro \
    -layers "met3 met4"

# Optional: Add standard cell rails if enabled
if { $::env(FP_PDN_ENABLE_RAILS) == 1 } {
    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $::env(FP_PDN_RAIL_LAYER) \
        -width $::env(FP_PDN_RAIL_WIDTH) \
        -followpins \
        -starts_with POWER

    add_pdn_connect \
        -grid stdcell_grid \
        -layers "$::env(FP_PDN_RAIL_LAYER) met4"
}