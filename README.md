# CODIF.jl

This is a Julia package for working with headers defined by the CSIRO
Oversampled Data Interchange Format specification v1.2.  It provides the
`CODIFHeader` structure which describes a CODIF v1.2 header.  Most CODIF header
items are fields in this structure and can be accessed by name, but this package
also provides functions to access the sub-fields on the `small_items` field.
The names of the fields and accessor functions closely follow the naming
conventions of the CODIF v1.2 specification, but some have been modified for
brevity.

A `getntime(::CODIFHeader)` function is also provided to obtain the number of
time samples in the data frame (or packet) described by a `CODIFHeader`.  This
function assumes that the data corresponding to a `CODIFHeader` contains all
time samples for the given `(data_frame, thread_id, group_id, secondary_id,
station_id)`.  If that is not the case for your application you will have to
scale the results as appropriate.

# Other useful packages

If you will be working with many `CODIFHeader` instances you may find these
packages convenient:

* [`StructArrays`](https://juliaarrays.github.io/StructArrays.jl/stable/)
* [`DataFrames`](https://dataframes.juliadata.org/stable/)

These packages are not dependencies of `CODIF.jl`, but they work well together.

A weak dependency of `CODIF.jl` is [`Pcap.jl`](
https://github.com/JuliaIO/Pcap.jl.git).  `CODIF.jl` has an extension that adds
`CODIFHeader` constructor methods that take a `Pcap.PktRec` or `Pcap.UdpHdr`
object.  This extension also makes `PcapOffline` readers iterable (a temporary
hack until this functionality can be merged into `Pcap.jl`).

A minor complication with using `Pcap.jl` is that it is not in the General
registry.  The GitHub URL for this package has been given in the `[sources]`
section of `Project.toml`, so if `CODIF` is your active environment, you can
still `]add Pcap` or `]dev Pcap` if using a Julia version >= 1.11.  One option
is to `]dev` it with this project activated and then for other projects that use
`CODIF` you can `]dev Pcap` and the already cloned repo should be found (though
that package should also have `Pcap.jl` in the `[sources]` section of its
`Project.toml` file).

# Additional functionality

`CODIF.jl` has extra functionality related to the CSIRO cryoPAF receiver.  This
functionality will likely be split off into a separate package at some point.
For now the only extra functionality is the `cryopaf_get_scaling` function that
will return the per-polarization per-packet scaling factors from the metadata
field.  Currently the metadata is blindly treated as "output 1 metadata", so do
not use this function if using another cryoPAF output type (unless it has
compatible metadata usage).
