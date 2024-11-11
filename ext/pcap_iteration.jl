#---
# PcapOffline iteration (should be moved to Pcap.jl)

function Base.iterate(pcap::PcapOffline, _=pcap)
    ifelse(eof(pcap.file), nothing, (pcap_get_record(pcap), pcap))
end

 Base.IteratorSize(::Type{PcapOffline}) = Base.SizeUnknown()
 Base.eltype(::Type{PcapOffline}) = PcapRec
 Base.isdone(pcap::PcapOffline, _=pcap) = eof(pcap.file)
