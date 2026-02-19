module CODIF

export CODIFHeader, getntime

# Small values accessor functions
export sample_representation, iscalenabled, iscomplex, isinvalid, isatypical
export protocol, version

export cryopaf_scaling_factors

"""
Strcture that maps directly to a CODIF header.  The field names are taken from
the CODIF spec with some modifcations for brevity.  This structure has the same
field layout as the CODIF header, which makes it possible to reinterpret a 64
element Vector{UInt8} as a CODIFHeader.
"""
struct CODIFHeader
    # Word 0
    data_frame::UInt32
    epoch_offset::UInt32
    # Word 1
    reference_epoch::UInt8
    sample_size::UInt8
    small_fields::UInt16
    reserved::UInt16
    alignment_period::UInt16
    # Word 2
    thread_id::UInt16
    group_id::UInt16
    secondary_id::UInt16
    station_id::UInt16
    # Word 3
    channels::UInt16
    sb_length::UInt16
    data_length::UInt32
    # Word 4
    samples_per_alignment_period::UInt64
    # Words 5-7
    sync_seq::UInt32
    metadata_id::UInt16
    metadata::NTuple{18, UInt8}
end

function CODIFHeader(bytes::AbstractVector{UInt8})
    if length(bytes) != 64
        error("must pass exactly 64 bytes, got $(length(bytes))")
    end
    reinterpret(CODIFHeader, bytes)[1]
end

function getntime(hdr::CODIFHeader)
    bytes_per_sample = hdr.sample_size ÷ 8 * (iscomplex(hdr)+1)
    bytes_per_channel_block = bytes_per_sample * hdr.channels
    bytes_per_sample_block = 8 * hdr.sb_length
    channel_blocks_per_sample_block = cld(bytes_per_sample_block, bytes_per_channel_block)
    sample_blocks_per_frame = hdr.data_length ÷ hdr.sb_length
    # Each channel block is a time sample
    ntime_per_frame = channel_blocks_per_sample_block * sample_blocks_per_frame
    ntime_per_frame
end

# Small fields are from bytes 2 and 3 of word 2.  Byte 2 is the LSB of
# `small_fields` and byte 3 is the MSB.

# Byte 2 (LSB of `small_fields`)

function sample_representation(small_fields::Integer)
    (small_fields >> 4) & 0xf
end

function iscalenabled(small_fields::Integer)
    (small_fields >> 3) & 0x1
end

function iscomplex(small_fields::Integer)
    (small_fields >> 2) & 0x1
end

function isinvalid(small_fields::Integer)
    (small_fields >> 1) & 0x1
end

function isatypical(small_fields::Integer)
    (small_fields     ) & 0x1
end

# Byte 3 (MSB of `small_fields`)

function protocol(small_fields::Integer)
    (small_fields >> 13) & 0x7
end

function version(small_fields::Integer)
    (small_fields >> 8) & 0x1f
end

# Byte 2 (LSB of `small_fields`)
sample_representation(hdr::CODIFHeader) = sample_representation(hdr.small_fields)
iscalenabled(hdr::CODIFHeader) = iscalenabled(hdr.small_fields)
iscomplex(hdr::CODIFHeader) = iscomplex(hdr.small_fields)
isinvalid(hdr::CODIFHeader) = isinvalid(hdr.small_fields)
isatypical(hdr::CODIFHeader) = isatypical(hdr.small_fields)
# Byte 3 (MSB of `small_fields`)
protocol(hdr::CODIFHeader) = protocol(hdr.small_fields)
version(hdr::CODIFHeader) = version(hdr.small_fields)

function cryopaf_scaling_factors(hdr::CODIFHeader)
    # Older versions of Julia can't reinterpret Ntuple{4,UInt8}
    reinterpret(Float32, reduce(+, Int32.(hdr.metadata[3:6]).<<(0:8:24))),
    reinterpret(Float32, reduce(+, Int32.(hdr.metadata[7:10]).<<(0:8:24)))
end

end # module CODIF
