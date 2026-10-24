using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace Lab10_API.Entities;

[Table("tblLoaiDeTai")]
public class TblLoaiDeTai
{
    [Key]
    [StringLength(15)]
    public string MaLoai { get; set; } = null!;

    [StringLength(50)]
    public string TenLoai { get; set; } = null!;

    [StringLength(150)]
    public string TenDayDu { get; set; } = null!;

    [StringLength(300)]
    public string? MoTa { get; set; }

    public int SoTinChi { get; set; } = 3;

    public int ThoiGianTuan { get; set; } = 15;

    [JsonIgnore]
    public virtual ICollection<TblDeTai> TblDeTais { get; set; } = new List<TblDeTai>();
}
