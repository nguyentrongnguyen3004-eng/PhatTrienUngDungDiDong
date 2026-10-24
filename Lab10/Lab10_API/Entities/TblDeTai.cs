using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace Lab10_API.Entities;

[Table("tblDeTai")]
public class TblDeTai
{
    [Key]
    [StringLength(15)]
    public string MaDeTai { get; set; } = null!;

    [StringLength(250)]
    public string TenDeTai { get; set; } = null!;

    [StringLength(100)]
    public string TenGiangVien { get; set; } = null!;

    [StringLength(500)]
    public string NoiDung { get; set; } = null!;

    [StringLength(400)]
    public string? YeuCau { get; set; }

    public int SoLuongSV { get; set; } = 2;

    [StringLength(30)]
    public string? HocKy { get; set; } = "HK2 (2025-2026)";

    [StringLength(50)]
    public string? TrangThai { get; set; } = "Đang mở đăng ký";

    [StringLength(15)]
    public string MaLoai { get; set; } = null!;

    [StringLength(15)]
    public string MaCN { get; set; } = null!;

    [JsonIgnore]
    [ForeignKey("MaLoai")]
    public virtual TblLoaiDeTai? LoaiDeTai { get; set; }

    [JsonIgnore]
    [ForeignKey("MaCN")]
    public virtual TblChuyenNganh? ChuyenNganh { get; set; }
}
