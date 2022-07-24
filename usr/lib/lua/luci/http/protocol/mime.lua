module("luci.http.protocol.mime",package.seeall)
require("luci.util")
MIME_TYPES={
["txt"]="text/plain";
["js"]="text/javascript";
["css"]="text/css";
["htm"]="text/html";
["html"]="text/html";
["patch"]="text/x-patch";
["c"]="text/x-csrc";
["h"]="text/x-chdr";
["o"]="text/x-object";
["ko"]="text/x-object";
["bmp"]="image/bmp";
["gif"]="image/gif";
["png"]="image/png";
["jpg"]="image/jpeg";
["jpeg"]="image/jpeg";
["svg"]="image/svg+xml";
["zip"]="application/zip";
["pdf"]="application/pdf";
["xml"]="application/xml";
["xsl"]="application/xml";
["doc"]="application/msword";
["ppt"]="application/vnd.ms-powerpoint";
["xls"]="application/vnd.ms-excel";
["odt"]="application/vnd.oasis.opendocument.text";
["odp"]="application/vnd.oasis.opendocument.presentation";
["pl"]="application/x-perl";
["sh"]="application/x-shellscript";
["php"]="application/x-php";
["deb"]="application/x-deb";
["iso"]="application/x-cd-image";
["tgz"]="application/x-compressed-tar";
["mp3"]="audio/mpeg";
["ogg"]="audio/x-vorbis+ogg";
["wav"]="audio/x-wav";
["mpg"]="video/mpeg";
["mpeg"]="video/mpeg";
["avi"]="video/x-msvideo";
}
function to_mime(e)
if type(e)=="string"then
local e=e:match("[^%.]+$")
if e and MIME_TYPES[e:lower()]then
return MIME_TYPES[e:lower()]
end
end
return"application/octet-stream"
end
function to_ext(e)
if type(e)=="string"then
for t,a in luci.util.kspairs(MIME_TYPES)do
if a==e then
return t
end
end
end
return nil
end
