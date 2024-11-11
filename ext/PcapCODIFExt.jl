module PcapCODIFExt

import CODIF: CODIFHeader

if isdefined(Base, :get_extension)
    using Pcap: PcapOffline, PcapRec, UdpHdr, decode_pkt, pcap_get_record
else
    using ..Pcap: PcapOffline, PcapRec, UdpHdr, decode_pkt, pcap_get_record
end

include("pcap_iteration.jl")

function CODIFHeader(udp::UdpHdr)
    CODIFHeader(@view udp.data[1:64])
end

function CODIFHeader(pkt::PcapRec)
    CODIFHeader(decode_pkt(pkt.payload).protocol)
end

end # module PcapCODIFExt