using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace Lab10_API.Entities;

[Table("tblChuyenNganh")]
public class TblChuyenNganh
{
    [Key]
    [StringLength(15)]
    public string MaCN { get; set; } = null!;

    [StringLength(100)]
    public string TenCN { get; set; } = null!;

    [StringLength(300)]
    public string MoTa { get; set; } = null!;

    [StringLength(20)]
    public string MaThongBao { get; set; } = null!;

    [StringLength(100)]
    public string? TruongBoMon { get; set; }

    [StringLength(50)]
    public string? IconName { get; set; } = "school";

    [JsonIgnore]
    public virtual ICollection<TblDeTai> TblDeTais { get; set; } = new List<TblDeTai>();
}
