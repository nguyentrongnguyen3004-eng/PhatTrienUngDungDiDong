using Lab10_API.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Lab10_API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ChuyenNganhController : ControllerBase
{
    private readonly QuanLyDeTaiContext _con;

    public ChuyenNganhController(QuanLyDeTaiContext context)
    {
        _con = context;
    }

    // GET: api/ChuyenNganh
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var list = await _con.TblChuyenNganhs
            .Select(x => new
            {
                x.MaCN,
                x.TenCN,
                x.MoTa,
                x.MaThongBao,
                x.TruongBoMon,
                x.IconName,
                SoLuongDeTai = x.TblDeTais.Count()
            })
            .ToListAsync();

        var order = new Dictionary<string, int>
        {
            { "CNPM", 1 },
            { "HTTT", 2 },
            { "MMT", 3 },
            { "ATTT", 4 },
            { "KHMT", 5 }
        };

        var sorted = list
            .OrderBy(x => order.TryGetValue(x.MaCN, out var idx) ? idx : 99)
            .ToList();

        return Ok(sorted);
    }

    // GET: api/ChuyenNganh/{id}
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id)
    {
        var item = await _con.TblChuyenNganhs.FirstOrDefaultAsync(x => x.MaCN == id);
        if (item == null)
        {
            return NotFound(new { message = $"Không tìm thấy chuyên ngành: {id}" });
        }
        return Ok(item);
    }

    // POST: api/ChuyenNganh
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TblChuyenNganh model)
    {
        try
        {
            if (await _con.TblChuyenNganhs.AnyAsync(x => x.MaCN == model.MaCN))
            {
                return BadRequest(new { message = $"Mã chuyên ngành '{model.MaCN}' đã tồn tại!" });
            }
            _con.TblChuyenNganhs.Add(model);
            await _con.SaveChangesAsync();
            return Ok(model);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = "Lỗi khi thêm chuyên ngành", error = ex.Message });
        }
    }

    // PUT: api/ChuyenNganh
    [HttpPut]
    public async Task<IActionResult> Update([FromBody] TblChuyenNganh model)
    {
        try
        {
            var existing = await _con.TblChuyenNganhs.FirstOrDefaultAsync(x => x.MaCN == model.MaCN);
            if (existing == null)
            {
                return NotFound(new { message = $"Không tìm thấy chuyên ngành: {model.MaCN}" });
            }
            existing.TenCN = model.TenCN;
            existing.MoTa = model.MoTa;
            existing.MaThongBao = model.MaThongBao;
            existing.TruongBoMon = model.TruongBoMon;
            existing.IconName = model.IconName;

            _con.TblChuyenNganhs.Update(existing);
            await _con.SaveChangesAsync();
            return Ok(existing);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = "Lỗi cập nhật chuyên ngành", error = ex.Message });
        }
    }

    // DELETE: api/ChuyenNganh/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        try
        {
            var existing = await _con.TblChuyenNganhs.FirstOrDefaultAsync(x => x.MaCN == id);
            if (existing == null)
            {
                return NotFound(new { message = $"Không tìm thấy chuyên ngành: {id}" });
            }
            _con.TblChuyenNganhs.Remove(existing);
            await _con.SaveChangesAsync();
            return Ok(new { message = $"Đã xóa chuyên ngành {id} thành công!" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = "Không thể xóa chuyên ngành này", error = ex.Message });
        }
    }
}
