using Lab10_API.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Lab10_API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class LoaiDeTaiController : ControllerBase
{
    private readonly QuanLyDeTaiContext _con;

    public LoaiDeTaiController(QuanLyDeTaiContext context)
    {
        _con = context;
    }

    // GET: api/LoaiDeTai
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var list = await _con.TblLoaiDeTais
            .Select(x => new
            {
                x.MaLoai,
                x.TenLoai,
                x.TenDayDu,
                x.MoTa,
                x.SoTinChi,
                x.ThoiGianTuan,
                SoLuongDeTai = x.TblDeTais.Count()
            })
            .ToListAsync();

        // Sắp xếp thứ tự chuẩn như hình minh họa: Đồ án -> KLKS -> Luận văn -> Khác
        var order = new Dictionary<string, int>
        {
            { "DA", 1 },
            { "KLKS", 2 },
            { "LV", 3 },
            { "KHAC", 4 }
        };

        var sorted = list
            .OrderBy(x => order.TryGetValue(x.MaLoai, out var idx) ? idx : 99)
            .ToList();

        return Ok(sorted);
    }

    // GET: api/LoaiDeTai/{id}
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id)
    {
        var item = await _con.TblLoaiDeTais.FirstOrDefaultAsync(x => x.MaLoai == id);
        if (item == null)
        {
            return NotFound(new { message = $"Không tìm thấy loại đề tài: {id}" });
        }
        return Ok(item);
    }

    // POST: api/LoaiDeTai
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TblLoaiDeTai model)
    {
        try
        {
            if (await _con.TblLoaiDeTais.AnyAsync(x => x.MaLoai == model.MaLoai))
            {
                return BadRequest(new { message = $"Mã loại đề tài '{model.MaLoai}' đã tồn tại!" });
            }
            _con.TblLoaiDeTais.Add(model);
            await _con.SaveChangesAsync();
            return Ok(model);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = "Lỗi khi thêm loại đề tài", error = ex.Message });
        }
    }

    // PUT: api/LoaiDeTai
    [HttpPut]
    public async Task<IActionResult> Update([FromBody] TblLoaiDeTai model)
    {
        try
        {
            var existing = await _con.TblLoaiDeTais.FirstOrDefaultAsync(x => x.MaLoai == model.MaLoai);
            if (existing == null)
            {
                return NotFound(new { message = $"Không tìm thấy mã loại: {model.MaLoai}" });
            }
            existing.TenLoai = model.TenLoai;
            existing.TenDayDu = model.TenDayDu;
            existing.MoTa = model.MoTa;
            existing.SoTinChi = model.SoTinChi;
            existing.ThoiGianTuan = model.ThoiGianTuan;

            _con.TblLoaiDeTais.Update(existing);
            await _con.SaveChangesAsync();
            return Ok(existing);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = "Lỗi cập nhật loại đề tài", error = ex.Message });
        }
    }

    // DELETE: api/LoaiDeTai/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        try
        {
            var existing = await _con.TblLoaiDeTais.FirstOrDefaultAsync(x => x.MaLoai == id);
            if (existing == null)
            {
                return NotFound(new { message = $"Không tìm thấy mã loại: {id}" });
            }
            _con.TblLoaiDeTais.Remove(existing);
            await _con.SaveChangesAsync();
            return Ok(new { message = $"Đã xóa loại đề tài {id} thành công!" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = "Không thể xóa loại đề tài này", error = ex.Message });
        }
    }
}
